# A class for managing backup volumes
define zpr::job (
  $files,
  $server,
  $parent,
  $snapshot      = 'on',
  $share         = undef,
  $share_nfs     = undef,
  $hour          = '0',
  $minute        = "fqdn_rand( 59 )",
  $keep          = '15', # 14 snapshots
  $ensure        = present,
  $compression   = undef,
  $zfs_tag       = 'stor-backups1',
  $zpr_tag       = 'backup-proxy1-prod',
  $readonly_tag  = 'crashplan-backups1',
  $backup_dir    = '/srv/backup',
  $quota         = '100G',
  $target        = undef, #to override zfs::rotate title
  $files_source  = $::fqdn,
  $rsync_hour    = '1',
  $rsync_minute  = "fqdn_rand( 59 )",
  $rsync_options = undef,
  $exclude_dir   = undef,
) {

  $vol_name  = "${parent}/${title}"
  $chown_vol = "chown nobody:nobody /${vol_name} ; chmod 0777 /${vol_name}"

  include zpr::user

  if $snapshot {
    @@zfs::snapshot { $title:
      target => $parent,
      tag    => $zfs_tag
    }
  }

  if $share {
    @@zfs::share { $title:
      share  => $share,
      parent => $parent,
      tag    => $zfs_tag
    }
  }

  @@zfs { $vol_name:
    ensure      => $ensure,
    name        => $vol_name,
    quota       => $quota,
    compression => $compression,
    sharenfs    => $share_nfs,
    notify      => Exec[$chown_vol],
    tag         => $zfs_tag
  }

  @@exec { $chown_vol:
    path        => '/usr/bin',
    refreshonly => true,
    require     => Zfs[$vol_name],
    tag         => $zfs_tag
  }

  @@file { "${backup_dir}/${title}":
    ensure => directory,
    tag    => [ $zpr_tag, $readonly_tag ]
  }

  @@mount { "${backup_dir}/${title}":
    ensure  => mounted,
    atboot  => true,
    fstype  => 'nfs',
    target  => '/etc/fstab',
    device  => "${server}:/${vol_name}",
    require => File["${backup_dir}/${title}"],
    tag     => [ $zpr_tag, $readonly_tag ]
  }

  @@zpr::rsync { $title:
    source_url    => $files_source,
    files         => $files,
    dest_folder   => "${backup_dir}/${title}",
    hour          => $rsync_hour,
    minute        => $rsync_minute,
    exclude_dir   => $exclude_dir,
    rsync_options => $rsync_options,
    tag           => $zpr_tag
  }

  if $share {
    @@zfs::share { $title:
      share  => $share,
      parent => $parent,
      tag    => $zfs_tag
    }
  }
}
