# Provides storage for zpr
class zpr::storage (
  $storage_tag = $zpr::params::storage_tag,
  $env_tag     = $zpr::params::env_tag,
) inherits zpr::params {

  if $env_tag {
    Zfs           <<| tag == $storage_tag and tag == 'zpr_vol' and tag == $env_tag |>>
    Zfs::Share    <<| tag == $storage_tag and tag == 'zpr_share' and tag == $env_tag |>>
    Zfs::Snapshot <<| tag == $storage_tag and tag == 'zpr_snapshot' and tag == $env_tag |>>
    File          <<| tag == $storage_tag and tag == 'zpr_vol' and tag == $env_tag |>>
  }
  else {
    Zfs           <<| tag == $storage_tag and tag == 'zpr_vol' |>>
    Zfs::Share    <<| tag == $storage_tag and tag == 'zpr_share' |>>
    Zfs::Snapshot <<| tag == $storage_tag and tag == 'zpr_snapshot' |>>
    File          <<| tag == $storage_tag and tag == 'zpr_vol' |>>
  }
}
