# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker (
  $tag        = $::hostname
) {

  File <<| tag == $tag |>>
  Mount <<| tag == $tag |>> {
    options => 'rw'
  }
  Zpr::Rsync <<| tag == $tag |>>
}
