# A class to install task-spooler
class zpr::resource::task_spooler (
  $ensure = latest
) {

  include zpr::params

  $pkg_name = $zpr::params::tsp_pkg_name

  package { $pkg_name:
    ensure => $ensure
  }
}
