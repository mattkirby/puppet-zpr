# A class to mount nfs volumes read-only for exporting as backups
class zpr::offsite {

  include zpr::params
  include zpr::user
  include zpr::resource::backup_dir

  $tag = $zpr::params::readonly_tag

  File <<|tag == $tag |>>
  Mount <<| tag == $tag |>> {
    options => 'ro'
  }
  Zpr::Duplicity <<| tag == $tag |>>
}
