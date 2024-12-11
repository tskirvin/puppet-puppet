## Unreleased


## Current

### [1.4.4]

* config.pp - switching from $::fqdn to help with puppet 8
* puppetserver.pp - processorcount to $facts['processor']['count']
* templates/puppetserver-webserver.erb - fqdn fixes again
* README updates to match

### [1.4.3]

* `spec/classes/puppetserver_java_spec.rb` - lint cleanup
* updated to work with PDK 1.15 (was 1.10)
* `puppet::config` - can now set `env_timeout` to `unlimited`

### [1.4.2]

* `puppetserver::java` - no longer setting Xms or Xmx parameters (they're
  no longer "required" in modern puppets after 6.1 or so)

* `puppet::agent` - when using an agent, actually set the `ensure`
  parameter had been configured (h/t @hammondr)

### [1.4.1]

* `puppetserver::java` - matching `^JAVA_ARGS=` instead of `JAVA_ARGS`
  because the latter matches multiple things now.

### [1.4.0]

* Adding 'ReservedCodeCache' size values to java args on puppet servers, 
  as per <https://puppet.com/docs/puppetserver/6.1/known_issues.html>

### [1.3.2]

* removing explicit connection to saz/rsyslog.  Trying to handle things 
  manually for now.

### [1.3.1]

* If `agent` is not set, then you also don't need `env` or `server`.
  This can come in handy for server-less setups.
* Reworked test suite for pdk 1.8.0 and modern Ruby.
* `strict_variables` added to puppet::config (by Morre <morre@mor.re>)

### [1.3.0]

* `puppet::config` - added lots of new parameters (mostly from Pat
  Riehecky <riehecky@fnal.gov>) - `proxy_host`, `configtimeout`,
  `log_level`, `runinterval`, `runtimeout`, `show_diff`, `splaylimit`,
  `strict`
* `puppet::agent` - cron-options are now much more powerful and useful
* `puppet::config` - removed `trusted_server_facts`
* `puppet::puppetserver` now does more things, but isn't as configurable;
  this is what I've been using upstream for a while though.
* `puppet::puppetserver::java` provides some java tuning options
* Significantly better test suite (pdk 1.7.0)

### [1.2.0]

* Puppet 4 support
* `puppet::config` - lots of new parameters, especially `extra_master`,
  `extra_main`, and `extra_agent`
* removed `manifests/master.pp` and `manifests/master/*` as no longer useful
* `manifests/puppetserver.pp` exists in basic form
* syslog stuff moved from `agent.pp` to `syslog.pp`
* Test suite works in modern world

### [1.1.1]

* Documentation fixes
* Documenting explicit support for RedHat instead of just Scientific Linux
* metadata.json - updates to better match upstream standards

### [1.1.0]

* Wrote a full test suite.
* Re-factored all modules in association with the test suite, to make the
  testing easier and more consistent.
* Documentation fixes

* top-level puppet manifest - now loads puppet::config

* puppet::agent 
  - added 'cron\_user' parameter
  - logdir is now a boolean instead of an empty string

* puppet::config
  - removed parameters: 'basedir', 'modules'
  - changed from default 'UNSET' to empty string: 'ca\_server', 'enc', 
    'reporturl'
  - explicitly checking the input values: 'env', 'port', 'server', 'timeout'
  - puppet.conf is explicitly less-verbose 

* puppet::master
  - removed parameters: 'contact', 'hiera'
  - no longer manage /etc/puppet/tagmail.conf

* puppet::master::mod\_passenger
  - renamed parameter 'basedir' to 'rackdir'
  - no longer require package 'rake'
  - manage Service['puppetmaster'] locally
  - disabling SSLv3 in the passenger fragment

* puppet::master::webrick
  - removed parameter 'is\_ca'
  - manage Service['puppetmaster'] locally

### [1.0.0]

* First public version.
