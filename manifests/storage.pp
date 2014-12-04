# Provides storage for zpr
class zpr::storage {

  include zpr::params

  $storage_tag = $zpr::params::storage_tag

  Zfs           <<| tag == $::current_environment and tag == $storage_tag |>>
  Zfs::Share    <<| tag == $::current_environment and tag == $storage_tag |>>
  Zfs::Snapshot <<| tag == $::current_environment and tag == $storage_tag |>>
  Zfs::Rotate   <<| tag == $::current_environment and tag == $storage_tag |>>
  Exec          <<| tag == $::current_environment and tag == $storage_tag |>>
}
