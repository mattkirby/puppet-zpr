# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker (
  $worker_tag = $zpr::params::worker_tag,
  $env_tag    = $zpr::params::env_tag,
) inherits zpr::params {

  $tags = [ $worker_tag, $env_tag ]

  include zpr::user
  include zpr::resource::backup_dir

  File       <<| tag == $tags |>>
  Mount      <<| tag == $tags |>> { options => 'rw' }
  Zpr::Rsync <<| tag == $tags |>>

}
