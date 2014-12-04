# A class to mount nfs volumes read-only for exporting as backups
class zpr::offsite {

  include zpr::params
  include zpr::user
  include zpr::resource::backup_dir

  $readonly_tag = $zpr::params::readonly_tag

  File <<|tag == $readonly_tag |>>
  Mount <<| tag == $readonly_tag |>> {
    options => 'ro'
  }
  Zpr::Duplicity <<| environment == $::environment and tag == $readonly_tag |>>
}
