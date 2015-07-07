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
# shipper
# Hostname of offsite worker. Useful if there are more than one. Default: shipper.
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
# s3_destination
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
  $ensure                = present,
  $collect_files         = true,
  $ship_offsite          = false,
  $create_vol            = true,
  $mount_vol             = true,
  $files_source          = $::fqdn,
  $storage               = undef,
  $worker                = undef,
  $shipper               = undef,
  $snapshot              = 'on',
  $keep                  = '15', # 14 snapshots
  $keep_s3               = '8W',
  $full_every            = '30D',
  $backup_dir            = undef, #toremove
  $zpr_home              = undef, #toremove
  $quota                 = undef,
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
  $compression           = 'on',
  $allow_ip_read         = undef,
  $allow_ip_write        = undef,
  $full_share            = undef,
  $target                = undef,
  $rsync_options         = undef,
  $exclude               = undef,
  $nosub                 = true,
  $prepend_title         = false
) {

  include zpr::params
  include zpr::user

  $storage_tag = pick($storage, $zpr::params::storage)
  $zpool       = $zpr::params::zpool

  $worker_tag     = pick($worker, $zpr::params::worker)
  $readonly_tag   = pick($shipper, $zpr::params::shipper)
  $backup_dir_p   = $zpr::params::backup_dir
  $home           = $zpr::params::home
  $anon_user_id   = $zpr::params::uid
  $s3_destination = $zpr::params::s3_destination
  $gpg_key_id     = $zpr::params::gpg_key_id
  $env_tag        = $zpr::params::env_tag
  $share_nfs      = 'on'

  if $allow_ip_read or $zpr::params::allow_ip_read {
    $allow_read = pick($allow_ip_read, $zpr::params::allow_ip_read)
  }

  $allow_write = pick($allow_ip_write, $zpr::params::allow_ip_write)

  if $ship_offsite {
    $allow_ip_read_default = $zpr::params::allow_ip_read_default
  }

  if $prepend_title {
    $utitle = "${::certname}_${title}"
  } else {
    $utitle = $title
  }

  $vol_name  = "${zpool}/${utitle}"

  if $title =~ /( )/ {
    fail("Backup resource ${title} cannot contain whitespace characters")
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
    if $s3_destination == undef {
      fail('No target is set')
    }
    else {
      @@zpr::duplicity { $utitle:
        target     => "${s3_destination}/${utitle}",
        hour       => $duplicity_hour,
        minute     => $duplicity_minute,
        files      => "${backup_dir_p}/${utitle}",
        keep       => $keep_s3,
        full_every => $full_every,
        tag        => [ $::current_environment, $readonly_tag, 'zpr_duplicity' ]
      }
      $ship_offsite_tags = concat($readonly_tags, $readonly_tag)
    }
  }
  else { $ship_offsite_tags = $readonly_tags }

  if $mount_vol {
    @@file { "${backup_dir_p}/${utitle}":
      ensure => directory,
      owner  => 'nobody',
      group  => 'nogroup',
      mode   => '0777',
      tag    => $ship_offsite_tags
    }

    @@mount { "${backup_dir_p}/${utitle}":
      ensure  => mounted,
      atboot  => true,
      fstype  => 'nfs',
      target  => '/etc/fstab',
      device  => "${storage}:/${vol_name}",
      require => File["${backup_dir_p}/${utitle}"],
      tag     => $ship_offsite_tags
    }
  }

  if $collect_files {
    zpr::rsync { $utitle:
      source_url    => $files_source,
      files         => $files,
      dest_folder   => "${backup_dir_p}/${utitle}",
      hour          => $rsync_hour,
      minute        => $rsync_minute,
      exclude       => $exclude,
      rsync_options => $rsync_options,
      worker        => $worker_tag,
    }
  }

  if ( $allow_read or $allow_ip_read_default or $allow_write or $full_share ) {
    if $allow_ip_read_default {
      $allow_ips_read_default = any2array($allow_ip_read_default)
    } else {
      $allow_ips_read_default = []
    }

    if $allow_read {
      $allow_ips_read = any2array($allow_read)
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
      allow_ip_write => $allow_write,
      security       => $security,
      zpool          => $zpool,
      full_share     => $full_share,
      anon_user_id   => $anon_user_id,
      nosub          => $nosub,
      tag            => concat($storage_tags, 'zpr_share')
    }
  }
}
