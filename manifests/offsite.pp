# A class to mount nfs volumes read-only for exporting as backups
class zpr::offsite (
  $readonly_tag = $zpr::params::readonly_tag,
  $env_tag      = $zpr::params::env_tag
) inherits zpr::params {

  $tags = [ $readonly_tag, $env_tag ]

  include zpr::user
  include zpr::backup_dir
  if $env_tag {
    File           <<| tag == $readonly_tag and tag == $env_tag |>>
    Mount          <<| tag == $readonly_tag and tag == $env_tag |>> { options => 'ro'}
    Zpr::Duplicity <<| tag == $readonly_tag and tag == $env_tag |>>
  }
  else {
    File           <<| tag == $readonly_tag |>>
    Mount          <<| tag == $readonly_tag |>> { options => 'ro'}
    Zpr::Duplicity <<| tag == $readonly_tag |>>
  }
}
