# A class to install task-spooler
class zpr::resource::task_spooler (
  $ensure   = latest,
  $pkg_name = $zpr::params::tsp_pkg_name,
) inherits zpr::params {

  package { $pkg_name:
    ensure => $ensure
  }
}
