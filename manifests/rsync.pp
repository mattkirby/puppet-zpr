# rsync job designed for use with zpr
define zpr::rsync (
  $source_url,
  $files,
  $dest_folder   = "/srv/backup/${title}",
  $rsync_options = 'SahpE',
  $delete        = '--delete-after',
  $rsync_path    = 'sudo rsync',
  $rsync         = '/usr/bin/rsync',
  $user          = 'zpr_proxy',
  $hour          = '0',
  $minute        = '15',
  $key_path      = '/var/lib/zpr/.ssh',
  $key_name      = 'id_rsa',
  $ssh_options   = "ssh -o 'BatchMode yes' -i",
  $task_spooler  = '/usr/bin/tsp',
  $exclude       = undef
) {

  $authorized_commands_dir = "${key_path}/.authorized_commands"
  $ssh_key                 = "${key_path}/${key_name}"

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

  $base_cmd  = "${rsync} -${rsync_options} ${delete} ${exclude_dir}"
  $ssh_cmd   = "-e \"${ssh_options} ${ssh_key}\""
  $path_cmd  = "--rsync-path='${rsync_path}'"
  $dest_cmd  = "${user}@${source_url}:${source_files} ${dest_folder}"

  $rsync_cmd     = "${base_cmd} ${ssh_cmd} ${path_cmd} ${dest_cmd}"
  $rsync_cmd_tsp = "${task_spooler} ${rsync_cmd}"

  cron { "${title}_rsync_backup":
    command => $rsync_cmd_tsp,
    user    => $user,
    hour    => $hour,
    minute  => $minute
  }

  file { "${authorized_commands_dir}/${title}":
    ensure  => present,
    owner   => $user,
    group   => $user,
    content => $rsync_cmd,
    mode    => '0400'
  }
}
