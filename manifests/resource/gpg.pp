class zpr::resource::gpg {

  include zpr::params

  $user = $zpr::params::user

  gpg::agent { $user:
    options => [
      '--default-cache-ttl 999999999',
      '--max-cache-ttl     999999999',
      '--use-standard-socket'
    ]
  }
}
