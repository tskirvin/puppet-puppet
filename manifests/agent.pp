# puppet::agent
#
#   Manage the puppet agent.  By default, this means running the service
#   as a daemon, but configuration hooks are provided for running via cron
#   instead.  Most configuration should take place from hiera.
#
#   Note: /etc/puppet/puppet.conf is managed by puppet::config (which is
#   loaded from here, but still, go look over there!).
#
# == Parameters
#
#    cron_command   Command to run if we're running via cron.  The default
#                   should be looked at.
#    daemon_name    If we're running as a daemon, what is the daemon name?
#                   Defaults to 'puppet'.
#    logdir         Set up logging, pointing at this log directory.  Any
#                   logs go to ${logdir}/puppet.log, in addition to syslog.
#                   Defaults to 'false', so no additional logging will happen.
#    run_at_boot    Set this if you're running in 'cron' mode.
#    run_in_noop    If set, we won't actually make any changes.  Defaults to
#                   false.
#    run_interval   If running via cron, how often should we run?  Defaults
#                   to 30 (minutes).
#    run_method     'service' or 'cron'
#
# == Usage
#
#    class { 'puppet::agent': }
#    class { 'puppet::agent': logdir => '/var/log/puppet' }
#
# == Notes
#
#   Many of the defaults came from the original Garrett Honeycutt module, and
#   may not apply to us.
#
class puppet::agent (
  $cron_command = '/usr/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay',
  $daemon_name  = 'puppet',
  $logdir       = false,
  $run_at_boot  = false,
  $run_in_noop  = false,
  $run_interval = '30',
  $run_method   = 'service'
) inherits puppet::config {
  case $run_method {
    'service': {
      $daemon_ensure    = 'running'
      $daemon_enable    = true
      $cron_ensure      = 'absent'
      $my_cron_command  = undef
      $cron_user        = undef
      $cron_hour        = undef
      $cron_minute      = undef
    }
    'cron': {
      $daemon_ensure = 'stopped'
      $daemon_enable = false
      $cron_run_one  = fqdn_rand($run_interval)
      $cron_run_two  = fqdn_rand($run_interval) + 30
      $cron_ensure   = 'present'
      if $run_in_noop {
        $my_cron_command = "${cron_command} --noop"
      } else {
        $my_cron_command = $cron_command
      }
      $cron_user     = 'root'
      $cron_hour     = '*'
      $cron_minute   = [$cron_run_one, $cron_run_two]
    }
    default: {
      fail ("puppet::agent::run_method is ${run_method}; must be 'service' or 'cron'.")
    }
  }

  if $run_at_boot { $at_boot_ensure = 'present' }
  else            { $at_boot_ensure = 'absent'  }

  service { 'puppet_agent_daemon':
    name   => $daemon_name,
    enable => $daemon_enable,
  }

  cron { 'puppet_agent':
    ensure  => $cron_ensure,
    command => $my_cron_command,
    user    => $cron_user,
    hour    => $cron_hour,
    minute  => $cron_minute,
  }

  cron { 'puppet_agent_once_at_boot':
    ensure  => $at_boot_ensure,
    command => $my_cron_command,
    user    => $cron_user,
    special => 'reboot',
  }

  if ($logdir) {
    validate_absolute_path ($logdir)
    file { "${logdir}/puppet.log":
      owner => 'puppet',
      group => 'puppet',
      mode  => '0660'
    }
  }
}