# Provides storage for zpr
class zpr::stor (
  $tag = $::hostname
) {

  Zfs <<| tag == $tag |>>
  Zfs::Share <<| tag == $tag |>>
  Zfs::Snapshot <<| tag == $tag |>>
  Zfs::Rotate <<| tag == $tag |>>
  Exec <<| tag == $tag |>>
}
