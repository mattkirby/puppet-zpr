# Provides storage for zpr
class zpr::storage {

  include zpr::params

  $storage_tag = $zpr::params::storage_tag

  Zfs <<| current_environment == $::current_environment and tag == $storage_tag |>>
  Zfs::Share <<| current_environment == $::current_environment and tag == $storage_tag |>>
  Zfs::Snapshot <<| current_environment == $::current_environment and tag == $storage_tag |>>
  Zfs::Rotate <<| current_environment == $::current_environment and tag == $storage_tag |>>
  Exec <<| current_environment == $::current_environment and tag == $storage_tag |>>
}
