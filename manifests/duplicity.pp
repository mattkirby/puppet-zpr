define zpr::duplicity (
  $target,
  $files          = $name,
  $ensure         = present,
  $full_every     = '30D',
  $keep           = '8W',
  $hour           = '1',
  $minute         = '10',
  $task_spooler   = '/usr/bin/tsp -E',
  $options        = undef
) {

  include zpr::duplicity_pkg
  include zpr::gpg
  include zpr::aws
  include zpr::task_spooler
  include zpr::params

  # Set variables

  $user            = $zpr::params::user
  $home            = $zpr::params::home
  $aws_key_file    = $zpr::params::aws_key_file
  $gpg_key_id      = $zpr::params::gpg_key_id
  $gpg_agent_info  = "${home}/.gpg-agent-info"
  $duplicity       = '/usr/bin/duplicity'
  $default_options = [
    "--encrypt-key ${gpg_key_id}",
    "--sign-key ${gpg_key_id}",
    '--use-agent'
  ]

  # Assemble commands

  if is_array($files) {
    $join_files   = join( $files, ' --include ' )
    $source_files = "--include ${join_files}"
  }
  else {
    $source_files = $files
  }

  if $options {
    if ! is_array($options) {
      $options_c = $options
    }
    else {
      fail( "Duplicity options must be an array. You declared ${options}." )
    }
  }
  else {
    $options_c = $default_options
  }

  $cmd_prefix = join( [ $duplicity, $options_c ], ' ')
  $cmd_suffix   = "${source_files} ${target}"

  $environment_c = [
    "source ${gpg_agent_info};",
    "source ${home}/${aws_key_file};",
    'export GPG_AGENT_INFO;',
  ]

  $environment_command = join( $environment_c, ' ')

  $date        = 'time=$(date +%s)'
  $full        = "--full-if-older-than ${full_every} ${cmd_suffix} ; ${date}"
  $clean       = "remove-older-than ${keep} --force ${target} ; ${date}"
  $tsp         = "${task_spooler} /bin/bash -c"
  $base        = [ $tsp, '"', $environment_command, $cmd_prefix ]

  $full_cmd    = join( [ $base, $full, '"' ], ' ')
  $clean_cmd   = join( [ $base, $clean, '"'], ' ')

  cron {
  # Run full backups as configured witht incremental in beetween
    "Duplicity: full backup of ${title}":
      ensure  => $ensure,
      user    => $user,
      command => $full_cmd,
      hour    => $hour,
      minute  => $minute;
  # Remove old backups
    "Duplicity: remove old ${title} backups":
      ensure  => $ensure,
      user    => $user,
      command => $clean_cmd,
      hour    => $hour,
      minute  => $minute,
  }
}
