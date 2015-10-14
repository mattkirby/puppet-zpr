# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker (
  $worker_tag = $zpr::params::worker_tag
) inherits zpr::params {

  class { 'zpr::user': source_user => true }

  include zpr::backup_dir
  include zpr::task_spooler
  include zpr::lockfile_progs

  File  <<| tag == $worker_tag and tag == 'zpr_rsync' |>>
  File  <<| tag == $worker_tag and tag == 'zpr_vol' |>>
  Mount <<| tag == $worker_tag and tag == 'zpr_vol' |>> {
    options => 'defaults,sec=none' }
  Cron  <<| tag == $worker_tag and tag == 'zpr_rsync' |>>
  Concat::Fragment <<| tag == $worker_tag and tag == 'zpr_sshkey' |>>
}
