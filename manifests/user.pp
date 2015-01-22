# A class that creates and manages a proxy user for zpr
class zpr::user (
  $ensure      = present,
  $user        = $zpr::params::user,
  $group       = $zpr::params::group,
  $home        = $zpr::params::home,
  $uid         = $zpr::params::uid,
  $gid         = $zpr::params::gid,
  $user_tag    = $zpr::params::user_tag,
  $env_tag     = $zpr::params::env_tag,
  $source_user = $zpr::params::source_user,
  $key_name    = $zpr::params::key_name,
  $pub_key     = $zpr::params::pub_key,
  $wrapper     = '/usr/bin/zpr_wrapper.py',
) inherits zpr::params {

  $authorized_commands_dir = "${home}/.ssh/.authorized_commands"

  group { $group:
    ensure => $ensure,
    gid    => $gid
  }

  if $source_user {
$user_shell = '/bin/bash'

    zpr::resource::generate_ssh_key { $user:
      user  => $user,
      group => $user,
      home  => $home,
      bits  => '4096'
    }

    @@ssh_authorized_key { $::hostname:
      ensure  => $ensure,
      key     => $::zpr_ssh_pubkey,
      type    => 'ssh-rsa',
      user    => $user,
      tag     => [ $env_tag, $user_tag ],
      options => [
        "command=\"python ${wrapper}\"",
        'no-X11-forwarding',
        'no-port-forwarding',
        'no-agent-forwarding',
        'no-pty',
      ],
    }

    Sshkey <<| tag == $env_tag and tag == $user_tag |>> {
      require => User[$user]
    }
  }
  else {
    $user_shell = '/bin/sh'
  }

  user { $user:
    ensure     => $ensure,
    gid        => $gid,
    uid        => $uid,
    home       => $home,
    managehome => true,
    shell      => $user_shell,
    require    => Group[$group]
  }

  file { $wrapper:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0500',
    content => template('zpr/zpr_rsync_forced_commands.py.erb')
  }

  file { $authorized_commands_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0400'
  }

  ssh::allowgroup { $group: }
  sudo::entry { "${user}_rsync":
    entry => "${user} ALL=(ALL) NOPASSWD:/usr/bin/rsync"
  }

  @@sshkey { $::fqdn:
    ensure       => $ensure,
    host_aliases => $::primary_ip,
    key          => $::sshecdsakey,
    type         => 'ecdsa-sha2-nistp256',
    target       => "${home}/.ssh/known_hosts",
    tag          => [ $env_tag, $user_tag ],
  }

  Ssh_authorized_key <<| tag == $env_tag and tag == $user_tag |>> {
    require => User[$user]
  }

  if ( str2bool($::is_pe) == false ) {
    if ( $pub_key == '' ) {
      notify { 'No pub_key is set': }
    }
    else {
      ssh_authorized_key { $key_name:
        ensure => present,
        key    => $pub_key,
        type   => 'ssh-rsa',
        user   => $user,
        tag    => $user
      }
    }
  }
}
