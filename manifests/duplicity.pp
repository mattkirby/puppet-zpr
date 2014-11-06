define zpr::duplicity (
  $user,
  $target,
  $home,
  $key_id,
  $ensure        = present,
  $keep          = '8W',
  $hour          = '1',
  $minute        = '10',
  $monthday_inc  = [ range('2', '15'), range('17', '31') ],
  $monthday_full = [ '1', '16' ],
  $options       = []
) {

  include duplicity::install

  # Set variables

  $gpg_agent_info = "${home}/.gpg-agent-info"
  $lastrun        = "${home}/.lastrun"
  $duplicity      = '/usr/bin/duplicity'

  # Assemble commands

  $cmd_prefix = inline_template("${duplicity} <%= options.join(' ') %>")
  $cmd_suffix = "${name} ${target}"

  $environment_command = "source ${gpg_agent_info}; export GPG_AGENT_INFO;"

  $incr_cmd = "/bin/bash -c '${environment_command} ${cmd_prefix} incremental ${cmd_suffix}' && echo `date` > ${lastrun}"
  $full_cmd = "/bin/bash -c '${environment_command} ${cmd_prefix} full ${cmd_suffix}' && echo `date` > ${lastrun}"

  $clean_cmd = "/bin/bash -c '${environment_command} ${cmd_prefix} remove-older-than ${keep} --force ${target}'"

  cron {
  # Run nightly incrementals
    "Duplicity: incremental backup of ${title}":
      ensure      => $ensure,
      command     => $incr_cmd,
      user        => $user,
      hour        => $hour,
      minute      => $minute,
      monthday    => $monthday_inc,
      environment => $environment;
  # Run full backups once every two weeks or as configured
    "Duplicity: full backup of ${title}":
      ensure      => $ensure,
      command     => $full_cmd,
      user        => $user,
      hour        => $hour,
      minute      => $minute,
      monthday    => $monthday_full,
      environment => $environment;
  # Remove old backups
    "Duplicity: remove old ${title} backups":
      ensure      => $ensure,
      command     => $clean_cmd,
      user        => $user,
      hour        => $hour,
      environment => $environment
  }
}
