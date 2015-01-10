# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker (
  $worker_tag = $zpr::params::worker_tag,
  $env_tag    = $zpr::params::env_tag,
) inherits zpr::params {

  include zpr::resource::backup_dir
  include zpr::user

  File       <<| tag == $env_tag and tag == $worker_tag |>>
  Mount      <<| tag == $env_tag and tag == $worker_tag |>> {
    options => 'rw'
  }
  Zpr::Rsync <<| tag == $env_tag and tag == $worker_tag |>>
}
