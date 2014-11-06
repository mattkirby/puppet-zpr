define zpr::duplicity (
  $user,
  $target,
  $home,
  $key_id,
  $ensure        = present,
  $keep          = '8W',
  $hour          = '1',
  $minute        = '10',
  $monthday_inc  = [ '2', '3' ],#[ range('2', '15'), range('17', '31') ],
  $monthday_full = [ '1', '16' ],
  $options       = undef
) {

  include duplicity::install
  include zpr::resource::gpg

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
    $cmd_options = inline_template("${duplicity} <%= options.join(' ') %>")
  }
  else {
    $cmd_options = inline_template("${duplicity} <%= default_options.join(' ') %>")
  }
  $cmd_suffix  = "${name} ${target}"

  $environment_command = "source ${gpg_agent_info}; export GPG_AGENT_INFO;"

  $incr_cmd = "/bin/bash -c '${environment_command} ${cmd_prefix} incremental ${cmd_suffix}' && echo `date` > ${lastrun}"
  $full_cmd = "/bin/bash -c '${environment_command} ${cmd_prefix} full ${cmd_suffix}' && echo `date` > ${lastrun}"

  $clean_cmd = "/bin/bash -c '${environment_command} ${cmd_prefix} remove-older-than ${keep} --force ${target}'"

  Cron {
    ensure      => $ensure,
    user        => $user,
  }

  cron {
  # Run nightly incrementals
    "Duplicity: incremental backup of ${title}":
      command     => $incr_cmd,
      hour        => $hour,
      minute      => $minute,
      monthday    => $monthday_inc;
  # Run full backups once every two weeks or as configured
    "Duplicity: full backup of ${title}":
      command     => $full_cmd,
      hour        => $hour,
      minute      => $minute,
      monthday    => $monthday_full;
  # Remove old backups
    "Duplicity: remove old ${title} backups":
      command     => $clean_cmd,
      hour        => $hour;
  }
}
