# provide the permitted_commands directory
class zpr::rsync_cmd (
  $user               = $zpr::params::user,
  $home               = $zpr::params::home,
  $permitted_commands = $zpr::params::permitted_commands,
  $backup_dir         = $zpr::params::backup_dir,
  $env_tag            = $zpr::params::env_tag
) inherits zpr::params {

  file { "${home}/run_backup":
    ensure  => file,
    owner   => $user,
    mode    => '0500',
    content => template('zpr/run_backup.erb')
  }

  if $env_tag {
    File <<| tag == $::fqdn and tag == 'zpr_rsync' and tag == $env_tag |>>
  }
  else {
    File <<| tag == $::fqdn and tag == 'zpr_rsync' |>>
  }
}
