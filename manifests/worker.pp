# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker {

  include zpr::params
  include zpr::resource::backup_dir

  $worker_tag = $zpr::params::worker_tag

  File       <<| tag == $::current_environment and tag == $worker_tag |>>
  Mount      <<| tag == $::current_environment and tag == $worker_tag |>> {
    options => 'rw'
  }
  Zpr::Rsync <<| tag == $::current_environment and tag == $worker_tag |>>
}
