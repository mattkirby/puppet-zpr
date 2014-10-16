# A class that creates and manages a proxy user for zpr
class zpr::user {

  $ensure = present
  $user   = hiera('zpr::user', 'zpr_proxy')
  $group  = $user
  $home   = hiera('zpr::home', '/var/lib/zpr')
  $uid    = '50555'
  $gid    = $uid
  $tag    = $::hostname

  # For placement of keys manually
  $key_name = undef
  $pub_key  = undef

  group { $group:
    ensure => $ensure,
    gid    => $gid
  }

  user { $user:
    ensure     => $ensure,
    gid        => $gid,
    uid        => $uid,
    home       => $home,
    managehome => true,
    shell      => '/bin/bash',
    require    => Group[$group]
  }

  ssh::allowgroup { $group: }
  sudo::entry { "${user}_rsync":
    entry => "${user} ALL=(ALL) NOPASSWD:/usr/bin/rsync"
  }

  zpr::resource::generate_ssh_key { $user:
    user  => $user,
    group => $user,
    home  => $home,
    bits  => '4096'
  }

  if ( $::zpr_ssh_pubkey ) {
    @@ssh_authorized_key { $::hostname:
      ensure  => $ensure,
      key     => $::zpr_ssh_pubkey,
      type    => 'ssh-rsa',
      user    => $user,
      tag     => $user,
      require => User[$user]
    }

    Ssh_authorized_key <<| tag == $tag |>>
  }

  if ( $::is_pe == 'false' ) {
    if ( $pub_key ) {
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
