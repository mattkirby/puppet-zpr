# Provides storage for zpr
class zpr::storage (
  $tag = 'storage'
) {

  Zfs <<| tag == $tag |>>
  Zfs::Share <<| tag == $tag |>>
  Zfs::Snapshot <<| tag == $tag |>>
  Zfs::Rotate <<| tag == $tag |>>
  Exec <<| tag == $tag |>>
}
