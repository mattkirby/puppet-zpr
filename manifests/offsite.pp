# A class to mount nfs volumes read-only for exporting as backups
class zpr::offsite {

  include zpr::params
  include zpr::user
  include zpr::resource::backup_dir

  $readonly_tag = $zpr::params::readonly_tag
  $env_tag      = $zpr::params::env_tag

  File           <<| tag == $env_tag and tag == $readonly_tag |>>
  Mount          <<| tag == $env_tag and tag == $readonly_tag |>> {
    options => 'ro'
  }
  Zpr::Duplicity <<| tag == $env_tag and tag == $readonly_tag |>>
}
