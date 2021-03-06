class zpr::params inherits zpr{

  # User configuration
  $user  = pick($globals_user, 'zpr_proxy')
  $group = pick($globals_group, $user)
  $home  = pick($globals_home, '/var/lib/zpr')
  $uid   = pick($globals_uid, '50555')
  $gid   = pick($globals_gid, $uid)

  # Tag configurations. Useful for collecting tags on workers
  $worker_tag         = pick($globals_worker_tag, 'worker')
  $readonly_tag       = pick($globals_readonly_tag, 'readonly')
  $storage            = $globals_storage
  $env_tag            = pick($globals_env_tag, 'default_env_tag')
  $sanity_check       = $globals_sanity_check
  $permitted_commands = pick($globals_permitted_commands, "${home}/.ssh/permitted_commands")

  $backup_dir        = pick($globals_backup_dir, '/srv/backup')
  $duplicity_version = pick($globals_duplicity_version, present)

  # For manual public key placement
  $pub_key  = $globals_pub_key
  $key_name = pick($globals_key_name, "${pub_key}_default")

  $tsp_pkg_name      = pick($globals_tsp_pkg_name, 'task-spooler')
  $lockfile_pkg_name = pick($globals_lockfile_pkg_name, 'lockfile-progs')
  $slots             = pick($globals_slots, '1')
  $maxfinished       = pick($globals_maxfinished, '1500')

  # AWS access keys
  $aws_key_file   = pick($globals_aws_key_file, '.aws')
  $aws_access_key = $globals_aws_access_key
  $aws_secret_key = $globals_aws_secret_key

  # GPG key data
  $gpg_passphrase = $globals_gpg_passphrase
  $gpg_key_grip   = $globals_gpg_key_grip
  $gpg_cache_ttl  = pick($globals_gpg_cache_ttl, '864000')
  $gpg_max_ttl    = pick($globals_gpg_max_ttl, $gpg_cache_ttl)
}
