class zpr::gpg (
  $user           = $zpr::params::user,
  $uid            = $zpr::params::uid,
  $home           = $zpr::params::home,
  $gpg_passphrase = $zpr::params::gpg_passphrase,
  $gpg_key_grip   = $zpr::params::gpg_key_grip,
  $gpg_cache_ttl  = $zpr::params::gpg_cache_ttl,
  $gpg_max_ttl    = $zpr::params::gpg_max_ttl
) inherits zpr::params {

  gpg::agent { $user:
    gpg_passphrase => $gpg_passphrase,
    gpg_key_grip   => $gpg_key_grip,
    user           => $user,
    outfile        => "${home}/.gpg-agent-info",
    options        => [
      "--default-cache-ttl ${gpg_cache_ttl}",
      "--max-cache-ttl ${gpg_max_ttl}",
      '--use-standard-socket'
    ]
  }

  file { "${home}/killgpg":
    ensure  => file,
    owner   => $user,
    mode    => '0500',
    content => template('zpr/killgpg.erb')
  }

  cron { 'kill_gpg_agent':
    command => "${home}/killgpg",
    user    => $user,
    weekday => '0',
    hour    => '17',
    minute  => '0'
  }
}
