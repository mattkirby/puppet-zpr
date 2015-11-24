# A class to mount nfs volumes read-only for exporting as backups
class zpr::offsite (
  $readonly_tag = $zpr::params::readonly_tag
) inherits zpr::params {

  include zpr::user
  include zpr::backup_dir
  include zpr::task_spooler
  include zpr::lockfile_progs
  include zpr::gpg

  File  <<| tag == $readonly_tag and tag == 'zpr_vol' |>>
  Mount <<| tag == $readonly_tag and tag == 'zpr_vol' |>> {
    options => 'defaults,ro,sec=none'
  }
  Zpr::Duplicity <<| tag == $readonly_tag and tag == 'zpr_duplicity' |>>
}
