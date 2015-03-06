# A class to mount nfs volumes read-only for exporting as backups
class zpr::offsite (
  $readonly_tag = $zpr::params::readonly_tag,
  $env_tag      = $zpr::params::env_tag
) inherits zpr::params {

  $tags = [ $readonly_tag, $env_tag ]

  include zpr::user
  include zpr::resource::backup_dir

  File           <<| tag == $tags |>>
  Mount          <<| tag == $tags |>> { options => 'ro'}
  Zpr::Duplicity <<| tag == $tags |>>

}
