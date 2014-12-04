# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker {

  include zpr::params
  include zpr::resource::backup_dir

  $worker_tag = $zpr::params::worker_tag

  File <<| environment == $::environment and tag == $worker_tag |>>
  Mount <<| environment == $::environment and tag == $worker_tag |>> {
    options => 'rw'
  }
  Zpr::Rsync <<| environment == $::environment and tag == $worker_tag |>>
}
