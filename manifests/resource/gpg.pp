class zpr::resource::gpg (
  $name = $zpr::params::user
) inherits zpr::params {

  gpg::agent { $name:
    options => [
      '--default-cache-ttl 999999999',
      '--max-cache-ttl     999999999',
      '--use-standard-socket'
    ]
  }
}


