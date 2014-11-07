define zpr::duplicity (
  $user,
  $target,
  $home,
  $key_id,
  $aws_key_file,
  $ensure         = present,
  $keep           = '8W',
  $hour           = '1',
  $minute         = '10',
  $monthday_inc   = concat( range('2', '15'), range ('17', '31')),
  $monthday_full  = [ '1', '16' ],
  $monthday_clean = '*',
  $task_spooler   = '/usr/bin/tsp',
  $options        = undef
) {

  include duplicity::install
  include zpr::resource::gpg
  include zpr::resource::aws
  include zpr::resource::task_spooler

  # Set variables

  $gpg_agent_info  = "${home}/.gpg-agent-info"
  $lastrun         = "${home}/.lastrun"
  $duplicity       = '/usr/bin/duplicity'
  $default_options = [
    "--encrypt-key ${key_id}",
    "--sign-key ${key_id}",
    '--use-agent'
  ]

  # Assemble commands

  if $options {
    $cmd_prefix = inline_template("${duplicity} <%= options.join(' ') %>")
  }
  else {
    $cmd_prefix = inline_template("${duplicity} <%= default_options.join(' ') %>")
  }
  $cmd_suffix   = "${name} ${target}"

  $environment_command = "source ${gpg_agent_info}; source ${aws_key_file}; export GPG_AGENT_INFO;"

  $full        = "full ${cmd_suffix}' && echo `date` > ${lastrun}"
  $incremental = "incremental ${cmd_suffix}' && echo `date` > ${lastrun}"
  $clean       = "remove-older-than ${keep} --force ${target}"
  $base        = "${task_spooler} /bin/bash -c"

  $full_cmd    = "${base} '${environment_command} ${cmd_prefix} ${full}"
  $incr_cmd    = "${base} '${environment_command} ${cmd_prefix} ${incremental}"
  $clean_cmd   = "${base} '${environment_command} ${cmd_prefix} ${clean}'"

  Cron {
    ensure      => $ensure,
    user        => $user
  }

  cron {
  # Run nightly incrementals
    "Duplicity: incremental backup of ${title}":
      command  => $incr_cmd,
      hour     => $hour,
      minute   => $minute,
      monthday => $monthday_inc;
  # Run full backups once every two weeks or as configured
    "Duplicity: full backup of ${title}":
      command  => $full_cmd,
      hour     => $hour,
      minute   => $minute,
      monthday => $monthday_full;
  # Remove old backups
    "Duplicity: remove old ${title} backups":
      command  => $clean_cmd,
      hour     => $hour,
      minute   => $minute,
      monthday => $monthday_clean
  }
}
