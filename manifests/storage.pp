# Provides storage for zpr
class zpr::storage {

  include zpr::params

  $tag = $zpr::params::storage_tag

  Zfs <<| tag == $tag |>>
  Zfs::Share <<| tag == $tag |>>
  Zfs::Snapshot <<| tag == $tag |>>
  Zfs::Rotate <<| tag == $tag |>>
  Exec <<| tag == $tag |>>
}
