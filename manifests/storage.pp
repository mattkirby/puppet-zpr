# Provides storage for zpr
class zpr::storage {

  include zpr::params

  $storage_tag = $zpr::params::storage_tag

  Zfs <<| tag == $storage_tag |>>
  Zfs::Share <<| tag == $storage_tag |>>
  Zfs::Snapshot <<| tag == $storage_tag |>>
  Zfs::Rotate <<| tag == $storage_tag |>>
  Exec <<| tag == $storage_tag |>>
}
