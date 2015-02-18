class zpr::backup_dir (
  $backup_dir = $zpr::params::backup_dir,
  $user       = $zpr::params::user,
) inherits zpr::params {

  file { $backup_dir:
    ensure => directory,
    owner  => $user,
    mode   => '0744'
  }
}
