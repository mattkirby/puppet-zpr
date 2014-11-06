class zpr::resource::backup_dir {

  include zpr::user
  include zpr::params

  $backup_dir = $zpr::params::backup_dir

  file { $backup_dir:
    ensure => directory,
    owner  => $zpr::params::user,
    mode   => '0744'
  }
}
