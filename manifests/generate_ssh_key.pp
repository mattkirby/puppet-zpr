# A class that creates ssh keys without passphrases
define zpr::generate_ssh_key (
  $user  = 'zpr',
  $group = 'zpr',
  $home = '/opt/zpr',
  $path = '/usr/bin',
  $bits = '2048'
) {

  $generate_key = "sudo -u ${user} ssh-keygen -t rsa -b ${bits} -N \"\" -f ${home}/.ssh/id_rsa"

  File {
    owner => $user,
    group => $group
  }

  file {
    "${home}/.ssh":
      ensure => directory;
    "${home}/.ssh/known_hosts":
      ensure  => file,
      require => File["${home}/.ssh"];
  }

  exec { "create_${::hostname}_ssh_key":
    cwd     => $home,
    command => $generate_key,
    creates => "${home}/.ssh/id_rsa",
    path    => '/usr/bin',
    require => File["${home}/.ssh"]
  }
}
