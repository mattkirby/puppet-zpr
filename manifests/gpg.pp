class zpr::gpg (
  $user           = $zpr::params::user,
  $home           = $zpr::params::home,
  $gpg_passphrase = $zpr::params::gpg_passphrase,
  $gpg_key_grip   = $zpr::params::gpg_key_grip,
) inherits zpr::params {

  gpg::agent { $user:
    gpg_passphrase => $gpg_passphrase,
    gpg_key_grip   => $gpg_key_grip,
    user           => $user,
    outfile        => "${home}/.gpg-agent-info",
    options        => [
      '--default-cache-ttl 999999999',
      '--max-cache-ttl     999999999',
      '--use-standard-socket'
    ]
  }
}
