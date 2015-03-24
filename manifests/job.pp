# == Define: zpr::job
#
# This define type creates a backup job to be collected by zpr resources
#
# === Actions:
#
# Creates exported resources for backup components:
# rsync job for collection on backup worker
# zfs volume for collection on storage server
# Snapshot job and rotation for zfs volume
# If selected, a duplicity job for the offsite worker
#
# === Sample Usage:
#
#  zpr::job { 'my-backup':
#    files  => [ '/path/to/files', '/path/to/more/files' ],
#    server => 'my-storage-server.example.com',
#    zpool  => 'tank',
#    quota  => '1T',
#    keep   => '100',
#    hour   => '*',
#  }
#
# === Parameters:
# files:
# Path to files or folders to backup.
#
# storage
# FQDN for storage server.
#
# zpool
# ZFS volume to create backup volumes within.
#
# ensure
# Allow resources to be ensurable. Default: present.
#
# collect_files
# Allow file collection to be disabled. Default: true.
#
# ship_offsite
# Ship backups offsite. Default: false.
#
# create_vol
# Allows disabling zfs volume creation. Default: true.
#
# mount_vol
# Allows disabling volume mount on worker. Default: true.
#
# files_source
# Source for files specified in files. Default: $::fqdn.
#
# worker_tag
# Hostname of worker to run rsync jobs. Useful if there are more than one. Default: worker.
#
# readonly_tag
# Hostname of offsite worker. Useful if there are more than one. Default: worker.
#
# snapshot
# Optionally disable snapshot creation. Default: true.
#
# keep
# How many snapshots to keep. Default: 15.
#
# keep_s3
# How long to keep offsite backups. Default: 12W.
#
# full_every
# How often to take full offsite backups. Default: 30D.
#
# backup_dir
# Where to mount backup volumes on workers. Default: /srv/backup.
#
# zpr_home
# zpr_proxy home directory. Default: /var/lib/zpr
#
# quota
# Disk quota for zfs volumes. Default: 100G.
#
# permissions
# Permissions for zfs volume access over nfs. Default: ro.
#
# security
# Security for zfs volume access over nfs. Default: none.
#
# hour
# Default hour for all cron related tasks. Default: 1.
#
# minute
# Default minute for all cron related tasks. Default: fqdn_rand(59)
#
# rsync_hour
# Rsync job hour. Default: $hour
#
# rsync_minute
# Rsync job minute. Default: $minute
#
# duplicity_hour
# Duplicity job hour. Default: $hour
#
# duplicity_minute
# Duplicity job minute. Default: $minute
#
# snapshot_hour
# Snapshot job hour. Default: $hour
#
# snapshot_minute
# Snapshot job minute. Default: $minute
#
# snapshot_r_hour
# Snapshot rotation hour. Default: $hour
#
# snapshot_r_minute
# Snapshot rotation minute. Default: $minute
#
# s3_target
# Target s3 bucket for offsite backups
#
# gpg_key_id
# GPG key ID for encrypting duplicity backups
#
# compression
# Whether to enable compression on zfs volume. Default: gzip.
#
# allow_ip
# IP address to permit access to the zfs volume over nfs
#
# share_nfs
# Whether to enable sharing over nfs.
#
# target
# Allows overriding the title used when searching for zfs snapshots to rotate.
#
# rsync_options
# Rsync options to use when collecting files. Default: SahpE.
#
# exclude
# Path or file type to exclude from rsync job.
#
# env_tag
# A tag to optionally limit a backup job to a particular environment.
#

define zpr::job (
  $files,
  $storage,
  $zpool,
  $ensure            = present,
  $collect_files     = true,
  $ship_offsite      = false,
  $create_vol        = true,
  $mount_vol         = true,
  $files_source      = $::fqdn,
  $worker_tag        = 'worker',
  $readonly_tag      = 'readonly',
  $snapshot          = 'on',
  $keep              = '15', # 14 snapshots
  $keep_s3           = '8W',
  $full_every        = '30D',
  $backup_dir        = '/srv/backup',
  $zpr_home          = '/var/lib/zpr',
  $quota             = '100G',
  $permissions       = 'ro',
  $security          = 'none',
  $hour              = '1',
  $minute            = fqdn_rand(59),
  $rsync_hour        = $hour,
  $rsync_minute      = $minute,
  $duplicity_hour    = $hour,
  $duplicity_minute  = $minute,
  $snapshot_hour     = $hour,
  $snapshot_minute   = $minute,
  $snapshot_r_hour   = $hour,
  $snapshot_r_minute = $minute,
  $s3_target         = undef,
  $gpg_key_id        = undef,
  $compression       = undef,
  $allow_ip          = undef,
  $share_nfs         = undef,
  $target            = undef, #to override zfs::rotate title
  $rsync_options     = undef,
  $exclude           = undef,
  $env_tag           = $::current_environment,
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
      hour   => $snapshot_hour,
      minute => $snapshot_minute,
      rhour  => $snapshot_r_hour,
      rmin   => $snapshot_r_minute,
      tag    => [ $::current_environment, $storage, 'zpr_snapshot' ],
    }
  }

  if $create_vol {
    @@zfs { $vol_name:
      ensure      => $ensure,
      name        => $vol_name,
      quota       => $quota,
      compression => $compression,
      sharenfs    => $share_nfs,
      tag         => [ $::current_environment, $storage, 'zpr_vol' ],
    }

    @@file { "/${vol_name}":
      owner => 'nobody',
      group => 'nobody',
      mode  => '0777',
      tag   => [ $::current_environment, $storage, 'zpr_vol' ],
    }
  }

  if $mount_vol {
    @@file { "${backup_dir}/${title}":
      ensure => directory,
      tag    => [ $::current_environment, $worker_tag, $readonly_tag , 'zpr_vol' ],
    }

    @@mount { "${backup_dir}/${title}":
      ensure  => mounted,
      atboot  => true,
      fstype  => 'nfs',
      target  => '/etc/fstab',
      device  => "${server}:/${vol_name}",
      require => File["${backup_dir}/${title}"],
      tag     => [ $::current_environment, $worker_tag, $readonly_tag, 'zpr_vol' ]
    }
  }

  if $collect_files {
    zpr::rsync { $title:
      source_url    => $files_source,
      files         => $files,
      dest_folder   => "${backup_dir}/${title}",
      hour          => $rsync_hour,
      minute        => $rsync_minute,
      exclude       => $exclude,
      rsync_options => $rsync_options,
      worker_tag    => $worker_tag,
    }
  }

  if $ship_offsite {
    if ( $gpg_key_id == undef ) or ( $s3_target == undef ) {
      fail('No key or target are set')
    }
    else {
      @@zpr::duplicity { $title:
        target     => "${s3_target}/${title}",
        hour       => $duplicity_hour,
        minute     => $duplicity_minute,
        home       => $zpr_home,
        files      => "${backup_dir}/${title}",
        key_id     => $gpg_key_id,
        keep       => $keep_s3,
        full_every => $full_every,
        tag        => [ $::current_environment, $readonly_tag, 'zpr_duplicity' ],
      }
    }
  }

  if $allow_ip {
    @@zfs::share { $title:
      allow_ip    => $allow_ip,
      permissions => $permissions,
      security    => $security,
      zpool       => $zpool,
      tag         => [ $::current_environment, $storage, 'zpr_share' ],
    }
  }
}
