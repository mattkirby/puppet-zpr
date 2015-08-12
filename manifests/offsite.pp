# A class to mount nfs volumes read-only for exporting as backups
class zpr::offsite (
  $readonly_tag = $zpr::params::readonly_tag,
  $env_tag      = $zpr::params::env_tag
) inherits zpr::params {

  include zpr::user
  include zpr::backup_dir
  include zpr::task_spooler
  include zpr::lockfile_progs

  if $env_tag {
    File  <<| tag == $readonly_tag and tag == 'zpr_vol' and tag == $env_tag |>>
    Mount <<| tag == $readonly_tag and tag == 'zpr_vol' and tag == $env_tag |>> {
      options => 'defaults,ro,sec=none'
    }
    Zpr::Duplicity <<| tag == $readonly_tag and tag == 'zpr_duplicity' and tag == $env_tag |>>
  }
  else {
    File  <<| tag == $readonly_tag and tag == 'zpr_vol' |>>
    Mount <<| tag == $readonly_tag and tag == 'zpr_vol' |>> {
      options => 'ro'
    }
    Zpr::Duplicity <<| tag == $readonly_tag and tag == 'zpr_duplicity' |>>
  }
}
