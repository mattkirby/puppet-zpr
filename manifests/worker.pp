# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker (
  $worker_tag = $zpr::params::worker_tag,
  $env_tag    = $zpr::params::env_tag,
) inherits zpr::params {

  class { 'zpr::user': source_user => true }

  include zpr::backup_dir
  include zpr::task_spooler
  include zpr::lockfile_progs

  if $env_tag {
    File  <<| tag == $worker_tag and tag == $env_tag and tag == 'zpr_rsync' |>>
    File  <<| tag == $worker_tag and tag == $env_tag and tag == 'zpr_vol' |>>
    Mount <<| tag == $worker_tag and tag == $env_tag and tag == 'zpr_vol' |>> {
      options => 'defaults,sec=none'
    }
    Cron  <<| tag == $worker_tag and tag == $env_tag and tag == 'zpr_rsync' |>>
    Concat::Fragment <<| tag == $worker_tag and tag == $env_tag and tag == 'zpr_sshkey' |>>
  }
  else {
    File  <<| tag == $worker_tag and tag == 'zpr_rsync' |>>
    File  <<| tag == $worker_tag and tag == 'zpr_vol' |>>
    Mount <<| tag == $worker_tag and tag == 'zpr_vol' |>> { options => 'rw' }
    Cron  <<| tag == $worker_tag and tag == 'zpr_rsync' |>>
    Concat::Fragment <<| tag == $worker_tag and tag == 'zpr_sshkey' |>>
  }
}
