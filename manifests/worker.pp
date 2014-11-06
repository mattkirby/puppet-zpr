# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker {

  include zpr::params
  include zpr::resource::backup_dir

  $tag = $zpr::params::worker_tag

  File <<| tag == $tag |>>
  Mount <<| tag == $tag |>> {
    options => 'rw'
  }
  Zpr::Rsync <<| tag == $tag |>>
}
