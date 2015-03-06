# Provides storage for zpr
class zpr::storage (
  $storage_tag = $zpr::params::storage_tag,
  $env_tag     = $zpr::params::env_tag,
) inherits zpr::params {

  $tags = [ $storage_tag, $env_tag ]

  Zfs           <<| tag == $tags |>>
  Zfs::Share    <<| tag == $tags |>>
  Zfs::Snapshot <<| tag == $tags |>>
  Zfs::Rotate   <<| tag == $tags |>>
  Exec          <<| tag == $tags |>>

}
