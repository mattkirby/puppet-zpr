class zpr::resource::aws (
  $home           = $zpr::params::home,
  $user           = $zpr::params::user,
  $aws_key_file   = $zpr::params::aws_key_file,
  $aws_access_key = $zpr::params::aws_access_key,
  $aws_secret_key = $zpr::params::aws_secret_key,
) inherits zpr::params {

  file { "${home}/${aws_key_file}":
    ensure  => file,
    owner   => $user,
    mode    => '0400',
    content => template('zpr/resource/aws.erb')
  }
}
