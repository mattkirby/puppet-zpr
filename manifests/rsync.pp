# rsync job designed for use with zpr
define zpr::rsync (
  $source_url,
  $files,
  $dest_folder    = "/srv/backup/${title}",
  $key_path       = '/var/lib/zpr/.ssh',
  $task_spooler   = '/usr/bin/tsp -E',
  $rsync          = '/usr/bin/rsync',
  $rsync_options  = 'rlpgoDShpEi',
  $delete         = '--delete-after',
  $rsync_path     = 'sudo rsync',
  $hour           = '0',
  $minute         = '15',
  $key_name       = 'id_rsa',
  $ssh_options    = ['SendEnv zpr_rsync_cmd', 'BatchMode yes'],
  $worker         = undef,
  $env_tag        = $::current_environment,
  $exclude        = undef
) {

  include zpr::rsync_cmd
  include zpr::params

  $user = $zpr::params::user
  $home = $zpr::params::home

  $permitted_commands = "${key_path}/permitted_commands"
  $ssh_key            = "${key_path}/${key_name}"
  $ssh_options_a      = any2array($ssh_options)
  $ssh_options_j      = join($ssh_options_a, "' -o '")
  $ssh_options_f      = "-o '${ssh_options_j}'"

  if $files != '' or $files {
    if ( is_array($files) ) {
      $source_files = join( $files, ' :')
    }
    else {
      $source_files = $files
    }

    if $exclude {
      if is_array($exclude) {
        $exclude_arr = join( $exclude, "' --exclude='")
        $exclude_dir = "--exclude='${exclude_arr}'"
      }
      else {
        $exclude_dir = "--exclude '${exclude}'"
      }
    }

    $rsync_cmd = [
      $task_spooler,
      '/bin/bash -c "',
      "${home}/run_backup",
      $title,
      ';',
      'time=$(date +%s)"'
    ]

    @@cron { "${title}_rsync_backup":
      command => join($rsync_cmd, ' '),
      user    => $user,
      hour    => $hour,
      minute  => $minute,
      tag     => [ $worker, $env_tag, 'zpr_rsync'],
    }

    @@file { "${permitted_commands}/${title}":
      owner   => $user,
      group   => $user,
      mode    => '0400',
      content => template('zpr/rsync.erb'),
      tag     => [ $worker, $env_tag, $source_url, 'zpr_rsync' ]
    }
  }
  else {
    warning( 'No files have been specified so no backups will be configured' )
  }
}
