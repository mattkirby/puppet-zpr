# Provides storage for zpr
class zpr::storage (
  $storage_tag = $zpr::params::storage_tag,
  $env_tag     = $zpr::params::env_tag,
) inherits zpr::params {

  if $env_tag {
    Zfs           <<| tag == $storage_tag and tag == $env_tag |>>
    Zfs::Share    <<| tag == $storage_tag and tag == $env_tag |>>
    Zfs::Snapshot <<| tag == $storage_tag and tag == $env_tag |>>
    Zfs::Rotate   <<| tag == $storage_tag and tag == $env_tag |>>
    File          <<| tag == $storage_tag and tag == $env_tag |>>
  }
  else {
    Zfs           <<| tag == $storage_tag |>>
    Zfs::Share    <<| tag == $storage_tag |>>
    Zfs::Snapshot <<| tag == $storage_tag |>>
    Zfs::Rotate   <<| tag == $storage_tag |>>
    File          <<| tag == $storage_tag |>>
  }
}
