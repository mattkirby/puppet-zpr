# A class for managing backup volumes
define zpr::job (
  $files,
  $server,
  $zpool,
  $ensure        = present,
  $collect_files = true,
  $ship_offsite  = false,
  $create_vol    = true,
  $mount_vol     = true,
  $files_source  = $::fqdn,
  $s3_target     = 's3+http://ploperations-backups',
  $gpg_key_id    = '44F93055',
  $storage_tag   = 'storage',
  $worker_tag    = 'worker',
  $readonly_tag  = 'readonly',
  $snapshot      = 'on',
  $keep          = '15', # 14 snapshots
  $keep_s3       = '8W',
  $backup_dir    = '/srv/backup',
  $zpr_home      = '/var/lib/zpr',
  $quota         = '100G',
  $compression   = undef,
  $allow_ip      = undef,
  $permissions   = 'ro',
  $security      = 'none',
  $share_nfs     = undef,
  $target        = undef, #to override zfs::rotate title
  $rsync_options = undef,
  $exclude       = undef,
  $hour          = '0',
  $minute        = fqdn_rand(59),
  $rsync_hour    = '1',
  $rsync_minute  = fqdn_rand(59),
  $limit_exports = true,
) {

  $vol_name  = "${zpool}/${title}"
  $chown_vol = "chown nobody:nobody /${vol_name} ; chmod 0777 /${vol_name}"

  include zpr::user

  if ( $limit_exports == true ) {
    $env = $::environment
  }
  else {
    $env = undef
  }

  if $snapshot {
    @@zfs::snapshot { $title:
      target => $zpool,
      tag    => "${env}${storage_tag}",
    }
  }

  if ( $create_vol == true ) {
    @@zfs { $vol_name:
      ensure      => $ensure,
      name        => $vol_name,
      quota       => $quota,
      compression => $compression,
      sharenfs    => $share_nfs,
      notify      => Exec[$chown_vol],
      tag         => "${env}${storage_tag}",
    }

    @@exec { $chown_vol:
      path        => '/usr/bin',
      refreshonly => true,
      require     => Zfs[$vol_name],
      tag         => "${env}${storage_tag}",
    }
  }

  if ( $mount_vol == true ) {
    @@file { "${backup_dir}/${title}":
      ensure => directory,
      tag    => [ "${env}${worker_tag}", "${env}${readonly_tag}" ],
    }

    @@mount { "${backup_dir}/${title}":
      ensure  => mounted,
      atboot  => true,
      fstype  => 'nfs',
      target  => '/etc/fstab',
      device  => "${server}:/${vol_name}",
      require => File["${backup_dir}/${title}"],
      tag     => [ "${env}${worker_tag}", "${env}${readonly_tag}" ]
    }
  }

  if ( $collect_files == true ) {
    @@zpr::rsync { $title:
      source_url    => $files_source,
      files         => $files,
      dest_folder   => "${backup_dir}/${title}",
      hour          => $rsync_hour,
      minute        => $rsync_minute,
      exclude       => $exclude,
      rsync_options => $rsync_options,
      tag           => "${env}${worker_tag}"
    }
  }

  if ( $ship_offsite == true ) {
    @@zpr::duplicity { $title:
      target => "${s3_target}/${title}",
      home   => $zpr_home,
      files  => "${backup_dir}/${title}",
      key_id => $gpg_key_id,
      keep   => $keep_s3,
      tag    => "${env}${readonly_tag}"
    }
  }

  if $allow_ip {
    @@zfs::share { $title:
      allow_ip    => $allow_ip,
      permissions => $permissions,
      security    => $security,
      zpool       => $zpool,
      tag         => "${env}${storage_tag}"
    }
  }
}
