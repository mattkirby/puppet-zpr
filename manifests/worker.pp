# A class to collect tasks to orchestrate zpr backup jobs
class zpr::worker (
  $worker_tag = $zpr::params::worker_tag,
  $env_tag    = $zpr::params::env_tag,
) inherits zpr::params {

  include zpr::user
  include zpr::backup_dir
  include zpr::task_spooler

  if $env_tag {
    File   <<| ( tag == 'zpr_rsync' or tag == 'zpr_vol' ) and tag == $worker_tag and tag == $env_tag |>>
    Mount  <<| tag == 'zpr_vol' and tag == $worker_tag and tag == $env_tag |>> { options => 'rw' }
    Cron   <<| tag == 'zpr_rsync' and tag == $worker_tag and tag == $env_tag |>>
    Sshkey <<| tag == 'zpr_sshkey' and tag == $worker_tag and tag == $env_tag |>>
  }
  else {
    File   <<| ( tag == 'zpr_rsync' or tag == 'zpr_vol' ) and tag == $worker_tag |>>
    Mount  <<| tag == 'zpr_vol' and tag == $worker_tag |>> { options => 'rw' }
    Cron   <<| tag == 'zpr_rsync' and tag == $worker_tag |>>
    Sshkey <<| tag == 'zpr_sshkey' and tag == $worker_tag |>>
  }
}
