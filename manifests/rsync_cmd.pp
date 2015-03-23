# provide the permitted_commands directory
class zpr::rsync_cmd (
  $permitted_commands = "${zpr::params::home}/.ssh/permitted_commands",
  $owner              = $zpr::params::user,
  $group              = $zpr::params::group,
) inherits zpr {

  file { $permitted_commands:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '0400',
  }

  File <<| tag == $::fqdn and tag == 'zpr_rsync' |>>

}
