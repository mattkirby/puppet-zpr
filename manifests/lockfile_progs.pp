# A class to manage the lockfile-progs package
class zpr::lockfile_progs (
  $ensure            = latest,
  $lockfile_pkg_name = $zpr::params::lockfile_pkg_name,
) inherits zpr::params {

  package { $lockfile_pkg_name:
    ensure => $ensure
  }
}
