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
# allow_ip_read
# IP address to permit read access to the zfs volume
#
# allow_ip_read_default
# Default IP address to permit read access
#
# allow_ip_write
# IP address to permit write access to the zfs volume
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
# anon_user_id
# A uid which, if set, sets the anon user value for zfs share
#
# nosub
# Whether to enable the nosub zfs share feature
#
# prepend_title
# Whether to make resource titles more unique by prepending certname
#

define zpr::job (
  $files,
  $storage,
  $zpool,
  $ensure                = present,
  $collect_files         = true,
  $ship_offsite          = false,
  $create_vol            = true,
  $mount_vol             = true,
  $share_nfs             = 'on',
  $files_source          = $::fqdn,
  $worker_tag            = 'worker',
  $readonly_tag          = 'readonly',
  $snapshot              = 'on',
  $keep                  = '15', # 14 snapshots
  $keep_s3               = '8W',
  $full_every            = '30D',
  $backup_dir            = '/srv/backup',
  $zpr_home              = '/var/lib/zpr',
  $quota                 = '100G',
  $security              = 'none',
  $hour                  = '1',
  $minute                = fqdn_rand(59),
  $rsync_hour            = $hour,
  $rsync_minute          = $minute,
  $duplicity_hour        = $hour,
  $duplicity_minute      = $minute,
  $snapshot_hour         = $hour,
  $snapshot_minute       = $minute,
  $snapshot_r_hour       = $hour,
  $snapshot_r_minute     = $minute,
  $s3_target             = undef,
  $gpg_key_id            = undef,
  $compression           = undef,
  $allow_ip_read         = undef,
  $allow_ip_read_default = undef,
  $allow_ip_write        = undef,
  $full_share            = undef,
  $target                = undef,
  $rsync_options         = undef,
  $exclude               = undef,
  $env_tag               = undef,
  $anon_user_id          = '50555',
  $nosub                 = true,
  $prepend_title         = false
) {

  if $prepend_title {
    $utitle = "${::certname}_${title}"
  } else {
    $utitle = $title
  }

  if $env_tag {
    $_env_tag = $env_tag
  } else {
    $_env_tag = $::zpr::params::env_tag
  }

  $vol_name  = "${zpool}/${utitle}"

  include zpr::user

  if $title =~ /(\s|=|,|@)/ {
    fail("Backup resource ${title} cannot contain whitespace or special characters")
  }

  $storage_tags = [ $::current_environment, $storage ]
  $readonly_tags = [ $::current_environment, $worker_tag, 'zpr_vol' ]

  if $snapshot {
    @@zfs::snapshot { $utitle:
      target => $zpool,
      hour   => $snapshot_hour,
      minute => $snapshot_minute,
      rhour  => $snapshot_r_hour,
      rmin   => $snapshot_r_minute,
      keep   => $keep,
      tag    => concat($storage_tags, 'zpr_snapshot')
    }
  }

  if $create_vol {
    @@zfs { $vol_name:
      ensure      => $ensure,
      name        => $vol_name,
      quota       => $quota,
      compression => $compression,
      sharenfs    => $share_nfs,
      tag         => concat($storage_tags, 'zpr_vol')
    }

    @@file { "/${vol_name}":
      owner => 'nobody',
      group => 'nogroup',
      mode  => '0777',
      tag   => concat($storage_tags, 'zpr_vol')
    }
  }

  if $ship_offsite {
    if ( $gpg_key_id == undef ) or ( $s3_target == undef ) {
      fail('No key or target are set')
    }
    else {
      @@zpr::duplicity { $utitle:
        target     => "${s3_target}/${utitle}",
        hour       => $duplicity_hour,
        minute     => $duplicity_minute,
        home       => $zpr_home,
        files      => "${backup_dir}/${utitle}",
        key_id     => $gpg_key_id,
        keep       => $keep_s3,
        full_every => $full_every,
        tag        => [ $::current_environment, $readonly_tag, 'zpr_duplicity' ]
      }
      $ship_offsite_tags = concat($readonly_tags, $readonly_tag)
    }
  }
  else { $ship_offsite_tags = $readonly_tags }

  if $mount_vol {
    @@file { "${backup_dir}/${utitle}":
      ensure => directory,
      owner  => 'nobody',
      group  => 'nogroup',
      mode   => '0777',
      tag    => $ship_offsite_tags
    }

    @@mount { "${backup_dir}/${utitle}":
      ensure  => mounted,
      atboot  => true,
      fstype  => 'nfs',
      target  => '/etc/fstab',
      device  => "${storage}:/${vol_name}",
      require => File["${backup_dir}/${utitle}"],
      tag     => $ship_offsite_tags
    }
  }

  if $collect_files {
    zpr::rsync { $utitle:
      source_url    => $files_source,
      files         => $files,
      dest_folder   => "${backup_dir}/${utitle}",
      hour          => $rsync_hour,
      minute        => $rsync_minute,
      exclude       => $exclude,
      rsync_options => $rsync_options,
      worker_tag    => $worker_tag,
    }
  }

  if ( $allow_ip_read or $allow_ip_read_default or $allow_ip_write or $full_share ) {
    if $allow_ip_read_default {
      $allow_ips_read_default = any2array($allow_ip_read_default)
    } else {
      $allow_ips_read_default = []
    }

    if $allow_ip_read {
      $allow_ips_read = any2array($allow_ip_read)
    } else {
      $allow_ips_read = []
    }

    $allow_read_ips_c = concat($allow_ips_read, $allow_ips_read_default)

    if ! empty($allow_read_ips_c) {
      $allow_read_ips = $allow_read_ips_c
    } else {
      $allow_read_ips = undef
    }

    @@zfs::share { $utitle:
      allow_ip_read  => $allow_read_ips,
      allow_ip_write => $allow_ip_write,
      security       => $security,
      zpool          => $zpool,
      full_share     => $full_share,
      anon_user_id   => $anon_user_id,
      nosub          => $nosub,
      tag            => concat($storage_tags, 'zpr_share')
    }
  }
}
