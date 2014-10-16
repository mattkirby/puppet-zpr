# rsync job define designed for use with the backup-proxy server and backup_proxy user
define zpr::rsync (
  $source_url,
  $files,
  $dest_folder    = "/srv/backup/${title}",
  $rsync_options  = 'SahpE',
  $delete         = '--delete-after',
  $rsync_path     = 'sudo rsync',
  $rsync          = '/usr/bin/rsync',
  $user           = 'backup_proxy',
  $hour           = '0',
  $minute         = '15',
  $key_path       = '/var/lib/backup/.ssh/id_rsa',
  $ssh_options    = 'ssh -o StrictHostKeyChecking=no -i',
  $task_spooler   = '/usr/bin/tsp',
  $exclude        = undef
) {

  include zpr::resource::task_spooler

  if ( $exclude ) {
    $rsync_command = "${task_spooler} ${rsync} -${rsync_options} ${delete} --exclude '${exclude}' -e \"${ssh_options} ${key_path}\" --rsync-path=\"${rsync_path}\" ${user}@${source_url}:${source_folder} ${dest_folder}"
  }
  else {
    $rsync_command = "${task_spooler} -${rsync_options} ${delete} -e \"${ssh_options} ${key_path}\" --rsync-path=\"${rsync_path}\" ${user}@${source_url}:${source_folder} ${dest_folder}"
  }

  cron { "${title}_rsync_backup":
    command => $rsync_command,
    user    => $user,
    hour    => $hour,
    minute  => $minute
  }
}
