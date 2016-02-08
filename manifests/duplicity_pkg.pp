# Install the duplicity package
class zpr::duplicity_pkg (
  $ensure   = $zpr::params::duplicity_version,
  $pkg_name = 'duplicity'
) inherits zpr::params {

  case $::operatingsystem {
    'Debian': { $boto = 'python-boto' }
    default:  { $boto = 'python-boto' }
  }

  package {
    $pkg_name:
      ensure => $ensure;
    $boto:
      ensure => present
  }
}
