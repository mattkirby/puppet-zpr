class zpr::resource::gpg {

  include zpr::params

  $name = $zpr::params::user

  gpg::agent { $name:
    options => [
      '--default-cache-ttl 999999999',
      '--max-cache-ttl     999999999',
      '--use-standard-socket'
    ]
  }
}
