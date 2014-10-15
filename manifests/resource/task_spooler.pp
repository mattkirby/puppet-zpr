# A class to install task-spooler
class zpr::resource::task_spooler (
  $pkg_name = 'task-spooler',
  $ensure   = 'latest'
) {

  package { $pkg_name:
    ensure => $ensure
  }
}
