# Install the duplicity package
class zpr::duplicity_pkg (
  $ensure   = $zpr::params::duplicity_version,
  $pkg_name = 'duplicity'
) inherits zpr::params {

  package { $pkg_name:
    ensure => $ensure
  }
}
