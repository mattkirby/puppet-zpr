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
  $storage_tag   = 'storage',
  $worker_tag    = 'worker',
  $readonly_tag  = 'readonly',
  $snapshot      = 'on',
  $keep          = '15', # 14 snapshots
  $keep_s3       = '8W',
  $full_every    = '30D',
  $backup_dir    = '/srv/backup',
  $zpr_home      = '/var/lib/zpr',
  $quota         = '100G',
  $permissions   = 'ro',
  $security      = 'none',
  $hour          = '0',
  $minute        = fqdn_rand(59),
  $rsync_hour    = '1',
  $rsync_minute  = fqdn_rand(59),
  $s3_target     = undef,
  $gpg_key_id    = undef,
  $compression   = undef,
  $allow_ip      = undef,
  $share_nfs     = undef,
  $target        = undef, #to override zfs::rotate title
  $rsync_options = undef,
  $exclude       = undef,
) {

  $vol_name  = "${zpool}/${title}"

  include zpr::user

  case $title {
    /( )/: {
      fail("Backup resource titles cannot contain whitespace characters. Please remove whitespace characters from your backup resource titled ${title}")
    }
  }

  if $snapshot {
    @@zfs::snapshot { $title:
      target => $zpool,
      tag    => [ $::current_environment, $storage_tag ],
    }
  }

  if $create_vol {
    @@zfs { $vol_name:
      ensure      => $ensure,
      name        => $vol_name,
      quota       => $quota,
      compression => $compression,
      sharenfs    => $share_nfs,
      tag         => [ $::current_environment, $storage_tag ],
    }

    @@file { "/${vol_name}":
      owner => 'nobody',
      group => 'nobody',
      mode  => '0777',
      tag   => [ $::current_environment, $storage_tag ],
    }
  }

  if $mount_vol {
    @@file { "${backup_dir}/${title}":
      ensure => directory,
      tag    => [ $::current_environment, $worker_tag, $readonly_tag ],
    }

    @@mount { "${backup_dir}/${title}":
      ensure  => mounted,
      atboot  => true,
      fstype  => 'nfs',
      target  => '/etc/fstab',
      device  => "${server}:/${vol_name}",
      require => File["${backup_dir}/${title}"],
      tag     => [ $::current_environment, $worker_tag, $readonly_tag ]
    }
  }

  if $collect_files {
    @@zpr::rsync { $title:
      source_url    => $files_source,
      files         => $files,
      dest_folder   => "${backup_dir}/${title}",
      hour          => $rsync_hour,
      minute        => $rsync_minute,
      exclude       => $exclude,
      rsync_options => $rsync_options,
      tag           => [ $::current_environment, $worker_tag ],
    }
  }

  if $ship_offsite {
    if ( $gpg_key_id == undef ) or ( $s3_target == undef ) {
      fail('No key or target are set')
    }
    else {
      @@zpr::duplicity { $title:
        target     => "${s3_target}/${title}",
        home       => $zpr_home,
        files      => "${backup_dir}/${title}",
        key_id     => $gpg_key_id,
        keep       => $keep_s3,
        full_every => $full_every,
        tag        => [ $::current_environment, $readonly_tag ],
      }
    }
  }

  if $allow_ip {
    @@zfs::share { $title:
      allow_ip    => $allow_ip,
      permissions => $permissions,
      security    => $security,
      zpool       => $zpool,
      tag         => [ $::current_environment, $storage_tag ],
    }
  }
}
