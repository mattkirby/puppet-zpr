# Provides storage for zpr
class zpr::storage {

  include zpr::params

  $storage_tag = $zpr::params::storage_tag
  $env_tag     = $zpr::params::env_tag

  Zfs           <<| tag == $env_tag and tag == $storage_tag |>>
  Zfs::Share    <<| tag == $env_tag and tag == $storage_tag |>>
  Zfs::Snapshot <<| tag == $env_tag and tag == $storage_tag |>>
  Zfs::Rotate   <<| tag == $env_tag and tag == $storage_tag |>>
  Exec          <<| tag == $env_tag and tag == $storage_tag |>>
}
