# A class to mount nfs volumes read-only for exporting as backups
class zpr::offsite {

  include zpr::params
  include zpr::user
  include zpr::resource::backup_dir

  $readonly_tag = $zpr::params::readonly_tag

  File           <<| tag == $::current_environment and tag == $readonly_tag |>>
  Mount          <<| tag == $::current_environment and tag == $readonly_tag |>> {
    options => 'ro'
  }
  Zpr::Duplicity <<| tag == $::current_environment and tag == $readonly_tag |>>
}
