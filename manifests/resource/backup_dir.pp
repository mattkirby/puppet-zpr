class zpr::resource::backup_dir (
  $backup_dir = '/srv/backup'
) {

  include zpr::user

  file { $backup_dir:
    ensure => directory,
    owner  => $user,
    mode   => '0744'
  }
}
