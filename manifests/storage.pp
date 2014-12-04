# Provides storage for zpr
class zpr::storage {

  include zpr::params

  $storage_tag = $zpr::params::storage_tag

  Zfs <<| environment == $::environment and tag == $storage_tag |>>
  Zfs::Share <<| environment == $::environment and tag == $storage_tag |>>
  Zfs::Snapshot <<| environment == $::environment and tag == $storage_tag |>>
  Zfs::Rotate <<| environment == $::environment and tag == $storage_tag |>>
  Exec <<| environment == $::environment and tag == $storage_tag |>>
}
