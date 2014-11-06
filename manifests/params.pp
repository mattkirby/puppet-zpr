class zpr::params {

  # User configuration
  $user         = hiera('zpr::user', 'zpr_proxy')
  $group        = hiera('zpr::group', $user)
  $home         = hiera('zpr::home', '/var/lib/zpr')
  $uid          = hiera('zpr::uid', '50555')
  $gid          = hiera('zpr::gid', $uid)

  # Tag configurations. Useful for collecting tags on workers
  $user_tag     = hiera('zpr::user_tag', 'backup-proxy1-prod')
  $storage_tag  = hiera('zpr::storage_tag', 'storage')
  $worker_tag   = hiera('zpr::worker_tag', 'worker')

  $backup_dir   = hiera('zpr::backup_dir', '/srv/backup')

  # For manual public key placement
  $key_name     = hiera('zpr::key_name', undef)
  $pub_key      = hiera('zpr::pub_key', undef)

  $tsp_pkg_name = hiera('zpr::tsp_pkg_name', 'task-spooler')

  # AWS access keys
  $aws_key_file   = hiera('zpr::aws_key_file', '.aws')
  $aws_access_key = hiera('zpr::aws_access_key', undef)
  $aws_secret_key = hiera('zpr::aws_secret_key', undef)
}
