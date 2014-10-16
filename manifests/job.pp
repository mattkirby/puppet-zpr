# A class for managing backup volumes
define zpr::job (
  $files,
  $server,
  $parent,
  $ensure        = present,
  $files_source  = $::fqdn,
  $storage_tag   = 'storage',
  $worker_tag    = 'worker',
  $readonly_tag  = 'readonly',
  $snapshot      = 'on',
  $keep          = '15', # 14 snapshots
  $backup_dir    = '/srv/backup',
  $quota         = '100G',
  $compression   = undef,
  $share         = undef,
  $share_nfs     = undef,
  $target        = undef, #to override zfs::rotate title
  $rsync_options = undef,
  $exclude       = undef,
  $hour          = '0',
  $minute        = fqdn_rand(59),
  $rsync_hour    = '1',
  $rsync_minute  = fqdn_rand(59)
) {

  $vol_name  = "${parent}/${title}"
  $chown_vol = "chown nobody:nobody /${vol_name} ; chmod 0777 /${vol_name}"

  include zpr::user

  if $snapshot {
    @@zfs::snapshot { $title:
      target => $parent,
      tag    => $storage_tag
    }
  }

  if $share {
    @@zfs::share { $title:
      share  => $share,
      parent => $parent,
      tag    => $storage_tag
    }
  }

  @@zfs { $vol_name:
    ensure      => $ensure,
    name        => $vol_name,
    quota       => $quota,
    compression => $compression,
    sharenfs    => $share_nfs,
    notify      => Exec[$chown_vol],
    tag         => $storage_tag
  }

  @@exec { $chown_vol:
    path        => '/usr/bin',
    refreshonly => true,
    require     => Zfs[$vol_name],
    tag         => $storage_tag
  }

  @@file { "${backup_dir}/${title}":
    ensure => directory,
    tag    => [ $worker_tag, $readonly_tag ]
  }

  @@mount { "${backup_dir}/${title}":
    ensure  => mounted,
    atboot  => true,
    fstype  => 'nfs',
    target  => '/etc/fstab',
    device  => "${server}:/${vol_name}",
    require => File["${backup_dir}/${title}"],
    tag     => [ $worker_tag, $readonly_tag ]
  }

  @@zpr::rsync { $title:
    source_url    => $files_source,
    files         => $files,
    dest_folder   => "${backup_dir}/${title}",
    hour          => $rsync_hour,
    minute        => $rsync_minute,
    exclude       => $exclude,
    rsync_options => $rsync_options,
    tag           => $worker_tag
  }

  if $share {
    @@zfs::share { $title:
      share  => $share,
      parent => $parent,
      tag    => $storage_tag
    }
  }
}
