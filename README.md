# puppet-puppet

This puppet module is meant to manage /etc/puppet/puppet.conf and its
family.  It provides hooks for rsyslog + logrotate, and is configurable
via hiera.

This module began life as a merge between
some old puppet code, the [ghoneycutt puppet
module](https://github.com/ghoneycutt/puppet-module-puppet), and a lot
of local custom work.  It's currently in production across at least two
sites, one large (~2700 nodes) and one small (~3 nodes).

## Classes

### puppet::agent

Manages the puppet agent.  This means either running the service as a
daemon (default), or via cron on a regular basis.

Parameters:

    cron_command      Command to run if we are running via cron.  There is a
                       default, and I do not use it much so somebody should
                       look at it in more detail.
    cron_user         User to run the cronjob as; defaults to 'root'.
    cron_run_at_boot  Set this if you're running in 'cron' mode.
    cron_run_in_noop  If set, we won't actually make any changes.  Defaults to
                       false.
    cron_run_interval If running via cron, how often should we run?  Defaults
                       to 30 (minutes).
    cron_earliest_hour Don't run the cronjob before this hour (except for boot)
    cron_latest_hour   Don't run the cronjob after this hour (except for boot)

    daemon_name      If we are running as a daemon, what is the daemon name?
                      Defaults to 'puppet'.
    run_method       Pick one of: 'service' or 'cron'; default is 'service'

### puppet::config

Manages `/etc/puppet/puppet.conf`.  It is meant for configuration via hiera.
There are puppet-strings-compatible docs included; a few specific useful
parameters should provide some flavor:

    agent        Should we configure the puppet agent variables?
                 Defaults to true.
    certname     Maps to the certname field in [main].  Defaults to $facts['networking']['fqdn']
    enc          Are we using an external node classifier?  If so, set
                 this to the right script name.  Defaults to 'false'.
    env          Default puppet environment; required.
    env_timeout  180 (seconds)
    is_ca        Am I the Certificate Authority?  Corresponds to the 'ca'
                 field.  Defaults to false.
    log_level    What severity should puppet use?  Defaults to 'notice'.
    master       Should we configure the puppet master variables?
                 Defaults to false.
    no_warnings  Array of strings from which to ignore warnings; maps to the
                 'disable_warnings' field.  Empty by default.
    runinterval  How often should the puppet daemon run?  Defaults to unset.
    runtimeout   What is the max runtime any catalog should have?
    run_in_noop  If set, don't make any changes with a puppet run.
                 Defaults to false.
    server       The main puppet server name.  Required, no default.
    splaylimit   How much random time should we add to runinterval?
                 Defaults to unset.
    strict       https://puppet.com/docs/puppet/5.5/configuration.html#strict
    use_puppetdb If set, turns on puppetdb for storeconfigs.  Defaults
                 to off.

### puppet::puppetserver, puppet::puppetserver::java

Start the `puppetserver` process.  Currently not very configurable.

### puppet::syslog

Set up syslog to log to `/var/log/puppet.log` (configurable).

# Prerequisites

* puppetlabs/stdlib
