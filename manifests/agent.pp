# puppet::agent
#
#   Manage the puppet agent.  By default, this means running the service
#   as a daemon, but configuration hooks are provided for running via cron
#   instead.  Most configuration should take place from hiera.
#
#   Note: /etc/puppetlabs/puppet/puppet.conf is managed by puppet::config
#   (which is loaded from here, but still, go look over there!).
#
# == Parameters
#
#    cron_command      Command to run if we're running via cron.  The default
#                       should be looked at.
#    cron_user         Defaults to 'root'.
#    cron_run_at_boot  Disable this if you're running in 'cron' mode.
#    cron_run_in_noop  If set, we won't actually make any changes.  Defaults to
#                       false.
#    cron_run_interval If running via cron, how often should we run?  Defaults
#                       to 30 (minutes).
#    cron_earliest_hour Don't run the cronjob before this hour (except for boot)
#    cron_latest_hour   Don't run the cronjob after this hour (except for boot)
#    daemon_name       If we're running as a daemon, what is the daemon name?
#                       Defaults to 'puppet'.
#    run_method        'service', 'cron', or 'manual'
#
# == Usage
#
#    include puppet::agent
#
# == Notes
#
#   Many of the defaults came from the original Garrett Honeycutt module, and
#   may not apply to us.
#
class puppet::agent (
  String $cron_command = '/opt/puppetlabs/bin/puppet agent -t',
  String $cron_user = 'root',
  Boolean $cron_run_at_boot = true,
  Boolean $cron_run_in_noop = false,
  Integer[30,180] $cron_run_interval = 30,    # more to it than that, but Enum is not okay
  Integer $cron_earliest_hour = 0,
  Integer $cron_latest_hour = 23,
  String $daemon_name  = 'puppet',
  Enum['service', 'cron', 'manual'] $run_method = 'cron'
) {
  require puppet::config

  if $cron_run_in_noop { $my_cron_command = "${cron_command} --noop" }
  else                 { $my_cron_command = $cron_command }

  case $run_method {
    'service': {
      $daemon_ensure    = 'running'
      $daemon_enable    = true
      $cron_ensure      = 'absent'
      $cron_hour        = undef
      $cron_minute      = undef
    }
    'cron': {
      $daemon_ensure = 'stopped'
      $daemon_enable = false
      $cron_ensure   = 'present'

      ## get ranges of hours; range comes from stdlib
      $all_hours = range('0', '23')
      $possible_hours = range("${cron_earliest_hour}", "${cron_latest_hour}") # lint:ignore:only_variable_string

      # if cron_run_interval is >1h, drop even numbered hours
      # if >2h also drop divisible by 3
      case $cron_run_interval {
        30, 60: { $my_hours = $possible_hours }
        120: { $my_hours = $possible_hours.filter |$hour| { $hour % 2 } }
        180: { $my_hours = $possible_hours.filter |$hour| { $hour % 3 } }
        default: { fail "invalid cron_run_interval ${cron_run_interval}, valid values: 30, 60, 120, 180" }
      }

      if ($possible_hours == $all_hours) { $cron_hour = ['*'] }
      else                               { $cron_hour = $my_hours }

      if ($cron_run_interval == 30) {
        $cron_run_one  = fqdn_rand($cron_run_interval)
        $cron_run_two  = fqdn_rand($cron_run_interval) + 30
        $cron_minute   = [$cron_run_one, $cron_run_two]
      } else {
        $cron_minute   = fqdn_rand(60, $cron_run_interval)
      }

    }
    'manual': {
      $daemon_ensure = 'stopped'
      $daemon_enable = false
      $cron_ensure   = 'absent'
      $cron_hour     = undef
      $cron_minute   = undef
    }
    default: { fail ("run_method: invalid value (${run_method})") }
  }

  if $cron_run_at_boot { $at_boot_ensure = 'present' }
  else                 { $at_boot_ensure = 'absent'  }

  service { 'puppet_agent_daemon':
    ensure => $daemon_ensure,
    name   => $daemon_name,
    enable => $daemon_enable,
  }

  cron { 'puppet_agent':
    ensure      => $cron_ensure,
    command     => $my_cron_command,
    environment => 'MAILTO=""',
    user        => $cron_user,
    hour        => $cron_hour,
    minute      => $cron_minute,
  }

  cron { 'puppet_agent_once_at_boot':
    ensure  => $at_boot_ensure,
    command => $my_cron_command,
    user    => $cron_user,
    special => 'reboot',
  }
}
