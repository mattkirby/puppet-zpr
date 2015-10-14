# Provides storage for zpr
class zpr::storage (
  $storage     = $zpr::params::storage
) inherits zpr::params {

  Zfs           <<| tag == $storage and tag == 'zpr_vol' |>>
  Zfs::Share    <<| tag == $storage and tag == 'zpr_share' |>>
  Zfs::Snapshot <<| tag == $storage and tag == 'zpr_snapshot' |>>
  File          <<| tag == $storage and tag == 'zpr_vol' |>>
}
