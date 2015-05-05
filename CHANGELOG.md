## Current

### [1.1.2]

* Added a 'timeout' parameter for puppet::config
* Added support for Debian 8 (well, it was already there)

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
