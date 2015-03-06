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
  $ssh_options    = 'ssh -o \'BatchMode yes\' -i',
  $exclude        = undef
) {

  include zpr::resource::task_spooler

  $ssh_key = "${key_path}/${key_name}"

  if ( is_array($files) ) {
    $source_files = inline_template("<%= @files.join(' :') %>")
  }
  else {
    $source_files = $files
  }

  if ( $exclude ) {
    $exclude_dir = "--exclude '${exclude}'"
  }
  else {
    $exclude_dir = undef
  }

  $command_components = [
    $task_spooler,
    $rsync,
    "-${rsync_options}",
    $delete,
    $exclude_dir,
    "-e \"${ssh_options}\"",
    "--rsync-path=\"${rsync_path}\"",
    "${user}@${source_url}:${source_files}",
    $dest_folder,
  ]

  $rsync_cmd = inline_template("<%= @command_components.join(' ') %>")

  cron { "${title}_rsync_backup":
    command => $rsync_cmd,
    user    => $user,
    hour    => $hour,
    minute  => $minute
  }
}
