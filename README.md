# puppet-puppet

This puppet module is meant to manage /etc/puppet/puppet.conf and its
family.  It provides hooks for rsyslog + logrotate, supports servers
running either mod\_passenger and webrick, and is configurable via hiera.  

This module began life as a merge between
some old puppet code, the [ghoneycutt puppet
module](https://github.com/ghoneycutt/puppet-module-puppet), and a lot
of local custom work.  It's currently in production across at least two
sites, one large (~1200 nodes) and one small (~3 nodes).

## Classes

### puppet::agent

Manages the puppet agent.  This means either running the service as a
daemon (default), or via cron on a regular basis.

Parameters:

     cron_command   Command to run if we are running via cron.  There is a
                    default, and I do not use it much so somebody should 
                    look at it in more detail.
     daemon_name    If we are running as a daemon, what is the daemon name?
                    Defaults to 'puppet'.
     logdir         Set up logging, pointing at this log directory.  Any
                    logs go to ${logdir}/puppet.log, in addition to syslog.
                    Defaults to 'false', so no additional logging will happen.
     run_at_boot    Set this if you're running in 'cron' mode.
     run_in_noop    If set, we won't actually make any changes.  Defaults to
                    false.
     run_interval   If running via cron, how often should we run?  Defaults
                    to 30 (minutes).
     run_method     'service' or 'cron'; default is 'service'

### puppet::config

Manages `/etc/puppet/puppet.conf`.  It is meant for configuration via hiera.

Parameters:

    agent        Should we configure the puppet agent variables?
                 Defaults to true.
    aliases      An array of alternate server names.  If set, you will
                 probably have to handle some manual steps to bring the
                 host up as part of a pool, involving signing the larger
                 cert; see:
 
                       http://docs.puppetlabs.com/guides/scaling_multiple_masters.html#before-running-puppet-agent-or-puppet-master
 
    basedir      Base directory for puppet configuration.  Defaults
                 to /etc/puppet.
    ca_server    Certificate authority server.  Defaults to 'UNSET',
                 which indicates that we will not explicitly set it.
    certname     Defaults to $::fqdn.
    config_path  /etc/puppet
    enc          Are we using an external node classifier?  If so, set
                 this to the right script name.  Defaults to 'false'.
    envdir       /etc/puppet/environments
    env_timeout  180 (seconds)
    is_ca        Am I the Certificate Authority?  Defaults to false.
    master       Should we configure the puppet master variables?
                 Defaults to false.
    modules      An array of module paths, relative to $basedir/ .
                 Defaults to [ 'modules' ].
    no_warnings  Array of strings from which to ignore warnings.
    port         Which port are we talking on?  Defaults to 8140.
    reports      Array of reports to send after a puppet run.  Defaults
                 empty; valid options include 'puppetdb' and 'tagmail'.
    reporturl    If we are sending an http report, where do we send it?
                 Defaults to 'UNSET'.
    run_in_noop  If set, don't make any changes with a puppet run.
                  Defaults to false.
    server       The main puppet server name.  Required, no default.
    use_puppetdb If set, turns on puppetdb for storeconfigs.  Defaults
                 to off.

### puppet::master

Configures a puppet master, either with webrick or mod\_passenger.

Parameters:

    contact   Array of email addresses that should be contacted with the
              'tagmail' report type.  Defaults to an empty array.
    is_ca     Are we the certificate authority?  Defaults to false; this is
              passed to puppet::master::{webrick|mod_passenger}.
    hiera     Should we load puppet::master::hiera ?  Default: false.
    logdir    Set up logging, pointing at this log directory.  Any logs
              go to ${logdir}/puppetmaster.log, in addition to syslog.
              Defaults to 'false', so no additional logging will happen.
    web       Which web server are we going to use to share the content with
              our clients?  Possible values:
 
                webrick    puppet::master::webrick       DEFAULT
                passenger  puppet::master::mod_passenger

#### puppet::master::hiera

Configures /etc/puppet/hiera.yaml, based on a local flat file.  This gets
loaded by puppet::master.  This should probably go somewhere else in the
future; consider it deprecated.

#### puppet::master::mod\_passenger

Use mod\_passenger (read: apache) for the puppetmaster.  

Parameters:

    basedir     Base system directory for the rack configuration; defaults
                to /usr/share/puppet/rack .
    is_ca       Am I the CA?  Defaults to either the hiera value of
                puppet::master::ca (which shares this value), or just false.
    port        Which network port are we using?  Defaults to 8140.
    puppetca    What is the puppetca?  Defaults to either the hiera value
                of puppet::config::ca_server, or undef.  Only used when
                $is_ca is not set, when we will instead proxy ca requests
                to the proper ca server.

#### puppet::master::webrick

Use webrick (the "default" way) for the puppetmaster.

Parameters:

    is_ca       Am I the CA?  Defaults to either the hiera value of
                puppet::master::ca (which shares this value), or just false.

## Prerequisites

* puppetlabs/stdlib
* saz/rsyslog

* puppetlabs/apache (for mod\_passenger only)
* puppetlabs/passenger (also for mod\_passenger only)
