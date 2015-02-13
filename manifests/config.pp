# puppet::config
#
#   Manage /etc/puppet/puppet.conf (or equivalent).  Most of the options
#   should be set in hiera.
#
# == Parameters
#
#    agent        Should we configure the puppet agent variables?
#                 Defaults to true.
#    aliases      An array of alternate server names.  If set, you'll
#                 probably have to handle some manual steps to bring the
#                 host up as part of a pool, involving signing the larger
#                 cert; see:
#
#                      http://docs.puppetlabs.com/guides/scaling_multiple_masters.html#before-running-puppet-agent-or-puppet-master
#
#    basedir      Base directory for puppet configuration.  Defaults
#                 to /etc/puppet.
#    ca_server    Certificate authority server.  Defaults to 'UNSET',
#                 which indicates that we won't explicitly set it.
#    certname     Defaults to $::fqdn.
#    config_path  /etc/puppet
#    enc          Are we using an external node classifier?  If so, set
#                 this to the right script name.  Defaults to 'false'.
#    envdir       /etc/puppet/environments
#    env_timeout  180 (seconds)
#    is_ca        Am I the Certificate Authority?  Defaults to false.
#    master       Should we configure the puppet master variables?
#                 Defaults to false.
#    modules      An array of module paths, relative to $basedir/ .
#                 Defaults to [ 'modules' ].
#    no_warnings  Array of strings from which to ignore warnings.
#    port         Which port are we talking on?  Defaults to 8140.
#    reports      Array of reports to send after a puppet run.  Defaults
#                 empty; valid options include 'puppetdb' and 'tagmail'.
#    reporturl    If we're sending an http report, where do we send it?
#                 Defaults to 'UNSET'.
#    run_in_noop  If set, don't make any changes with a puppet run.
#                 Defaults to false.
#    server       The main puppet server name.  Required, no default.
#    use_puppetdb If set, turns on puppetdb for storeconfigs.  Defaults
#                 to off.
#
# == Usage
#
#   class { 'puppet::config': server => 'cms-puppet.fnal.gov' }
#
class puppet::config (
  $agent        = true,
  $aliases      = [],
  $basedir      = '/etc/puppet',
  $ca_server    = 'UNSET',
  $certname     = $::fqdn,
  $config_path  = '/etc/puppet',
  $enc          = 'UNSET',
  $env          = $::env,
  $envdir       = '/etc/puppet/environments',
  $env_timeout  = 180,
  $is_ca        = false,
  $master       = false,
  $modules      = [ 'modules' ],
  $no_warnings  = [],
  $port         = 8140,
  $reports      = [],
  $reporturl    = 'UNSET',
  $run_in_noop  = false,
  $server       = undef,
  $use_puppetdb = false
) {
  validate_string ($server, $env)
  if ! $env { fail ('puppet::config::env must be set') }

  $modules_paths = prefix ($modules, "${basedir}/")

  if count($aliases) > 0 {
    validate_array($aliases)
    $dns_alt_names = concat ([$::fqdn], $aliases)
  }

  file { 'puppet.conf':
    path    => "${config_path}/puppet.conf",
    content => template('puppet/puppet.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }

  file { '/var/log/puppet':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0750'
  }
}
