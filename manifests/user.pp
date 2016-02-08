# A class that creates and manages a proxy user for zpr
class zpr::user (
  $ensure             = present,
  $user               = $zpr::params::user,
  $group              = $zpr::params::group,
  $home               = $zpr::params::home,
  $uid                = $zpr::params::uid,
  $gid                = $zpr::params::gid,
  $worker_tag         = $zpr::params::worker_tag,
  $env_tag            = $zpr::params::env_tag,
  $readonly_tag       = $zpr::params::readonly_tag,
  $source_user        = $zpr::params::source_user,
  $key_name           = $zpr::params::key_name,
  $pub_key            = $zpr::params::pub_key,
  $sanity_check       = $zpr::params::sanity_check,
  $permitted_commands = $zpr::params::permitted_commands,
  $wrapper            = '/usr/bin/zpr_wrapper.py',
) inherits zpr::params {

  if $user == undef {
    fail('::zpr::user parameter $user cannot be undef')
  }

  $known_hosts = "${home}/.ssh/known_hosts"

  $check_for_elements = [
    ';',
    '&',
    '\|',
    'authorized_keys',
    'sudoers',
    '/bin/.*',
    '/usr/bin/.*',
  ]

  if $::sshecdsakey {
    $ssh_key_concat = [
      "${::fqdn},${::primary_ip}",
      'ecdsa-sha2-nistp256',
      "${::sshecdsakey}\n"
    ]
  }
  elsif $::sshrsakey {
    $ssh_key_concat = [
      "${::fqdn},${::primary_ip}",
      'ssh-rsa',
      "${::sshrsakey}\n",
    ]
  }
  else {
    fail( 'Cannot find ecdsa, or rsa key to deploy for secure host checking' )
  }

  if $sanity_check {
    $check_for = $sanity_check
  }
  else {
    $check_for = join($check_for_elements, '|')
  }

  if $source_user {

    $user_shell = '/bin/bash'

    zpr::generate_ssh_key { $user:
      home => $home
    }

    @@ssh_authorized_key { $::hostname:
      ensure  => $ensure,
      key     => $::zpr_ssh_pubkey,
      type    => 'ssh-rsa',
      user    => $user,
      tag     => delete_undef_values([ $worker_tag, 'zpr_ssh_authorized_key' ]),
      options => [
        "command=\"${wrapper}\"",
        'no-X11-forwarding',
        'no-port-forwarding',
        'no-agent-forwarding',
        'no-pty',
      ],
    }

    concat { $known_hosts:
      owner => $user,
      group => $group,
      mode  => '0600',
    }

    $known_hosts_header = [
      '# HEADER: This file is managed by puppet.',
      "# HEADER: Manual changes will be stomped.\n",
    ]

    concat::fragment { 'known_hosts_header':
      target  => $known_hosts,
      content => join( $known_hosts_header, "\n" ),
      order   => 0
    }
  }
  elsif $::hostname == $readonly_tag {
    $user_shell = '/bin/bash'
  }
  else {
    $user_shell = '/bin/sh'

    zpr::generate_ssh_key { $user:
      home => $home,
      gen  => false
    }
  }

  group { $group:
    ensure => $ensure,
    gid    => $gid
  }

  user { $user:
    ensure  => $ensure,
    gid     => $gid,
    uid     => $uid,
    home    => $home,
    shell   => $user_shell,
    require => Group[$group]
  }

  file {
    $home:
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => '0755';
    $permitted_commands:
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => '0400';
    $wrapper:
      ensure  => present,
      owner   => $user,
      group   => $user,
      mode    => '0500',
      content => template('zpr/ssh_forced_commands_wrapper.py.erb');
    "${home}/.profile":
      ensure => present,
      owner  => $user,
      group  => $user,
      mode   => '0644'
  }

  ssh::allowgroup { $group: }
  sudo::entry { "${user}_rsync":
    entry => "${user} ALL=(ALL) NOPASSWD:/usr/bin/rsync"
  }

  @@concat::fragment { "${::certname}_ecdsakey":
    target  => $known_hosts,
    content => join( $ssh_key_concat, ' ' ),
    tag     => delete_undef_values([ $worker_tag, 'zpr_sshkey' ]),
  }

  Ssh_authorized_key <<| tag == $worker_tag and tag == 'zpr_ssh_authorized_key' |>> {
    require => User[$user]
  }

  if $pub_key {
    ssh_authorized_key { $key_name:
      ensure => present,
      key    => $pub_key,
      type   => 'ssh-rsa',
      user   => $user,
      tag    => $user
    }
  }

  include zpr::rsync_cmd
}
