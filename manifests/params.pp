class zpr::params {

  $user         = hiera('zpr::user', 'zpr_proxy')
  $group        = hiera('zpr::group', $user)
  $home         = hiera('zpr::home', '/var/lib/zpr')
  $uid          = hiera('zpr::uid', '50555')
  $gid          = hiera('zpr::gid', $uid)

  $user_tag     = hiera('zpr::user_tag', 'backup-proxy1-prod')
  $storage_tag  = hiera('zpr::storage_tag', 'storage')
  $worker_tag   = hiera('zpr::worker_tag', 'worker')

  $backup_dir   = hiera('zpr::backup_dir', '/srv/backup')

  $key_name     = hiera('zpr::key_name', undef)
  $pub_key      = hiera('zpr::pub_key', undef)

  $tsp_pkg_name = hiera('zpr::tsp_pkg_name', 'task-spooler')
}
