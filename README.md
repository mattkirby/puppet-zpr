puppet-zpr
==========
####Table of Contents
1. [Overview](#overview)
2. [Setup](#setup)
3. [Usage](#usage)
4. [Classes](#classes)
5. [Parameters](#parameters)
6. [Limitations](#limitations)
7. [Development](#development)
Rsync backups to zfs storage using puppet to orchestrate.

## Overview
This module configures backups using rsync and zfs as a storage backend. Additionally, offsite backups are supported with [Duplicity](http://duplicity.nongnu.org/).

## Setup

¸ Storage classes assume configuration is using Solaris 11 and ZFS. A Solaris 11 node is required for storage.
¸ Worker and offsite classes are configured for use on Debian. Pull requests are welcome to improve compatability with other operating systems.
¸ A Puppet installation using a master and PuppetDB are requirements in order for this to work since the module relies on exported resources.

On your storage node
```puppet
include zpr::storage
```

On your worker node
```puppet
include zpr::worker
```

## Usage
To declare a backup job
```puppet
zpr::job { 'my-backup':
  files   => [ '/path/to/files', '/path/to/more/files' ]
  exclude => '*.tmp',
  storage => 'storage.my-domain.com',
  worker  => 'worker.my-domain.com',
}
```

### Classes

#### Public Classes
- zpr: Main class to configure module defaults
- zpr::worker: Collects worker tasks and configures a user.
- zpr::storage: Collects zfs volumes for creation.
- zpr::job: Main define type for defining backup jobs.

#### Private Classes
- zpr::params
- zpr::rsync
- zpr::rsync_cmd
- zpr::duplicity
- zpr::user
- zpr::aws
- zpr::task_spooler

### Parameters

The following parameters are available for the zpr class:

#### `user`
Set the zpr user name. Default is 'zpr_proxy'
#### `group`
Set the zpr group name. Default is 'zpr_proxy'
#### `home`
Set the zpr user home directory. Default is '/var/lib/zpr'
#### `uid`
Set the zpr user UID. Default is '50555'
#### `gid`
Set the zpr user GID. Default is '50555'
#### `user_tag`
Set the user tag for zpr_proxy user reference. Default is 'worker'
#### `storage`
Configure the default storage server.
#### `worker_tag`
Configure the default worker tag. Usually set to fqdn or hostname of worker
#### `readonly_tag`
Set the tag for offsite backups. Default is 'offsite'
#### `env_tag`
Allows limiting resource collection to a specific environment
#### `source_user`
Determine whether to generate ssh keys and export them. Usually set on worker
#### `backup_dir`
Where to mount volumes on offsite and worker
#### `pub_key`
If manually setting keys set a ssh public key here
#### `sanity_check`
Accepts an array of regex values to search for in the ssh_original_command passed by rsync. Default is 
```puppet
[ ';', '&', '\|', 'authorized_keys', 'sudoers', '/bin/.*', '/usr/bin/.*'/, ]
```
#### `permitted_commands`
Path to permitted commands directory. Default is "${home}/.ssh/permitted_commands"
#### `key_name`
Name of key if setting manually. Default is "${pub_key}_default"
#### `tsp_pkg_name`
Name of tsp pkg. Default is 'task-spooler'
#### `aws_key_file`
Title of file to store AWS credentials. Default is '.aws'
#### `aws_access_key`
AWS access key for offsite backups
#### `aws_secret_key`
AWS secret key for offsite backups
#### `gpg_passphrase`
GPG passphrase to set for unattended backups
#### `gpg_key_grip`
Key grip of GPG key used for offsite backups
#### `duplicity_version`
Allow setting the version of Duplicity. Default is present

## Limitations

At this time the module has been designed with Solaris 11 used for storage, and Debian used for worker tasks. Support for other platforms can be added and pull requests are welcome.

## Development

Pull requests are welcome on github.
