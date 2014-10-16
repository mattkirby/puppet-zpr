# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker (
  $tag        = $::hostname
) {

  include zpr::resource::backup_dir

  File <<| tag == $tag |>>
  Mount <<| tag == $tag |>> {
    options => 'rw'
  }
  Zpr::Rsync <<| tag == $tag |>>
}
