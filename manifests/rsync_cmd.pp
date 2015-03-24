# provide the permitted_commands directory
class zpr::rsync_cmd (
  $env_tag = $zpr::params::env_tag
) inherits zpr::params {

  if $env_tag {
    File <<| tag == $::fqdn and tag == 'zpr_rsync' and tag == $env_tag |>>
  }
  else {
    File <<| tag == $::fqdn and tag == 'zpr_rsync' |>>
  }
}
