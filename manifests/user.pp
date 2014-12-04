# A class that creates and manages a proxy user for zpr
class zpr::user (
  $ensure = present
) {

  include zpr::params

  $user          = $zpr::params::user
  $group         = $zpr::params::group
  $home          = $zpr::params::home
  $uid           = $zpr::params::uid
  $gid           = $zpr::params::gid
  $user_tag      = $zpr::params::user_tag
  $source_user   = $zpr::params::source_user

  # For placement of keys manually
  $key_name = $zpr::params::key_name
  $pub_key  = $zpr::params::pub_key

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
    if ( $source_user == true ) {
      @@ssh_authorized_key { $::hostname:
        ensure => $ensure,
        key    => $::zpr_ssh_pubkey,
        type   => 'ssh-rsa',
        user   => $user,
        tag    => [ $::current_environment, $user_tag ],
      }
    }
  }

    Ssh_authorized_key <<| tag == $user_tag |>> {
      require => User[$user]
    }

  if ( $::is_pe == 'false' ) {
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
