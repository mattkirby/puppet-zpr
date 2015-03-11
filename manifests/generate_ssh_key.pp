# A class that creates ssh keys without passphrases
define zpr::generate_ssh_key (
  $home,
  $user  = $title,
  $group = $user,
  $path  = '/usr/bin',
  $bits  = '4096',
  $gen   = true
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

  if $gen {
    exec { "create_${::hostname}_ssh_key":
      cwd     => $home,
      command => $generate_key,
      creates => "${home}/.ssh/id_rsa",
      path    => '/usr/bin',
      require => File["${home}/.ssh"]
    }
  }
}
