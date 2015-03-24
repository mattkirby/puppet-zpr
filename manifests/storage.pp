# Provides storage for zpr
class zpr::storage (
  $storage     = $zpr::params::storage,
  $env_tag     = $zpr::params::env_tag,
) inherits zpr::params {

  if $env_tag {
    Zfs           <<| tag == $storage and tag == 'zpr_vol' and tag == $env_tag |>>
    Zfs::Share    <<| tag == $storage and tag == 'zpr_share' and tag == $env_tag |>>
    Zfs::Snapshot <<| tag == $storage and tag == 'zpr_snapshot' and tag == $env_tag |>>
    File          <<| tag == $storage and tag == 'zpr_vol' and tag == $env_tag |>>
  }
  else {
    Zfs           <<| tag == $storage and tag == 'zpr_vol' |>>
    Zfs::Share    <<| tag == $storage and tag == 'zpr_share' |>>
    Zfs::Snapshot <<| tag == $storage and tag == 'zpr_snapshot' |>>
    File          <<| tag == $storage and tag == 'zpr_vol' |>>
  }
}
