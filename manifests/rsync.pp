# rsync job define designed for use with the backup-proxy server and backup_proxy user
define zpr::rsync (
  $source_url,
  $files,
  $dest_folder    = "/srv/backup/${title}",
  $rsync_options  = 'SahpE',
  $delete         = '--delete-after',
  $rsync_path     = 'sudo rsync',
  $rsync          = '/usr/bin/rsync',
  $user           = 'zpr_proxy',
  $hour           = '0',
  $minute         = '15',
  $key_path       = '/var/lib/zpr/.ssh',
  $key_name       = 'id_rsa',
  $ssh_options    = 'ssh -o StrictHostKeyChecking=no -i',
  $task_spooler   = '/usr/bin/tsp',
  $exclude        = undef
) {

  $ssh_key = "${key_path}/${key_name}"

  if ( is_array($files) ) {
    $source_files = inline_template("<%= files.join(' :') %>")
  }
  else {
    $source_files = $files
  }

  include zpr::resource::task_spooler

  if ( $exclude ) {
    $exclude_dir = "--exclude '${exclude}'"
  }
  else {
    $exclude_dir = undef
  }

    $rsync_command = "${task_spooler} ${rsync} -${rsync_options} ${delete} ${exclude_dir} -e \"${ssh_options} ${ssh_key}\" --rsync-path=\"${rsync_path}\" ${user}@${source_url}:${source_files} ${dest_folder}"

  cron { "${title}_rsync_backup":
    command => $rsync_command,
    user    => $user,
    hour    => $hour,
    minute  => $minute
  }
}
