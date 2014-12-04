# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker {

  include zpr::params
  include zpr::resource::backup_dir

  $worker_tag = $zpr::params::worker_tag

  File <<| current_environment == $::current_environment and tag == $worker_tag |>>
  Mount <<| current_environment == $::current_environment and tag == $worker_tag |>> {
    options => 'rw'
  }
  Zpr::Rsync <<| current_environment == $::current_environment and tag == $worker_tag |>>
}
