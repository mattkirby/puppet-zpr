# rsync job designed for use with zpr
define zpr::rsync (
  $source_url,
  $files,
  $dest_folder    = "/srv/backup/${title}",
  $key_path       = '/var/lib/zpr/.ssh',
  $task_spooler   = '/usr/bin/tsp',
  $rsync          = '/usr/bin/rsync',
  $rsync_options  = 'SahpE',
  $delete         = '--delete-after',
  $rsync_path     = 'sudo rsync',
  $user           = 'zpr_proxy',
  $hour           = '0',
  $minute         = '15',
  $key_name       = 'id_rsa',
  $ssh_options    = "ssh -o 'SendEnv zpr_rsync_cmd' -o 'BatchMode yes' -i",
  $worker_tag     = undef,
  $env_tag        = $::current_environment,
  $exclude        = undef
) {

  include zpr::rsync_cmd

  $permitted_commands = "${key_path}/permitted_commands"
  $ssh_key            = "${key_path}/${key_name}"

  if $files != '' or $files {
    if ( is_array($files) ) {
      $source_files = join( $files, ' :')
    }
    else {
      $source_files = $files
    }

    $command_base = [
      $rsync,
      "-${rsync_options}",
      $delete,
    ]

    $command_args = [
      "-e \\\"${ssh_options}",
      "${ssh_key}\\\"",
      "--rsync-path='${rsync_path}'",
      "${user}@${source_url}:${source_files}",
      $dest_folder,
    ]

    if $exclude {
      if is_array($exclude) {
        $exclude_arr = join( $exclude, "' --exclude='")
        $exclude_dir = [ "--exclude='${exclude_arr}'" ]
      }
      else {
        $exclude_dir = [ "--exclude '${exclude}'" ]
      }
      $rsync_1   = concat( $command_base, $exclude_dir )
      $rsync_c   = concat( $rsync_1, $command_args )
    }
    else {
      $rsync_c = concat( $command_base, $command_args )
    }

    $rsync_cmd = join( $rsync_c, ' ' )
    $cat_cmd   = "cat ${permitted_commands}/${title}"

    $full_cmd = [
      $task_spooler,
      '/bin/bash -c',
      '"export',
      "zpr_rsync_cmd=\\\"$(${cat_cmd})\\\"",
      ';',
      "$(${cat_cmd} | tr -d '\\\\')\"",
    ]

    @@cron { "${title}_rsync_backup":
      command => join( $full_cmd, ' ' ),
      user    => $user,
      hour    => $hour,
      minute  => $minute,
      tag     => [ $worker_tag, $env_tag, 'zpr_rsync'],
    }

    @@file { "${permitted_commands}/${title}":
      owner   => $user,
      group   => $user,
      mode    => '0400',
      content => $rsync_cmd,
      tag     => [ $worker_tag, $env_tag, $source_url, 'zpr_rsync' ]
    }
  }
  else {
    warning( 'No files have been specified so no backups will be configured' )
  }
}
