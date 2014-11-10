# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker {

  include zpr::params
  include zpr::resource::backup_dir

  $worker_tag = $zpr::params::worker_tag

  File <<| tag == $worker_tag |>>
  Mount <<| tag == $worker_tag |>> {
    options => 'rw'
  }
  Zpr::Rsync <<| tag == $worker_tag |>>
}
