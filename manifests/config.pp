# puppet::config
#
#   Manage /etc/puppetlabs/puppet/puppet.conf for both agent and master
#   use.  It is designed to be configured via hiera.
#
# == Parameters
#
#    agent        Configure the [agent] section?  Default: true
#    aliases      An array of alternate server names, mapping to dns_alt_names
#                 (along with $certname).  If set, you'll probably have to
#                 handle some manual steps to bring the host up as part of a
#                 pool, involving signing the larger cert; see:
#                      http://docs.puppetlabs.com/guides/scaling_multiple_masters.html#before-running-puppet-agent-or-puppet-master
#    autosign     Script to run for puppet autosigning in [master].   Default: 
#                 empty.
#    ca_server    Maps to the ca_server field in the [agent] block if
#                 non-empty.  Defaults to an empty string,
#    certname     'certname' field in [main].  Default: $::fqdn.
#    config_path  /etc/puppetlabs/puppet
#    enc          Are we using an external node classifier?  If so, set
#                 this to the right script name.  Defaults to 'false'.
#    env
#    envdir       /etc/puppetlabs/code/environments
#    extra_agent
#    extra_main
#    extra_master
#    env          Default environment; no default, must be set.
#    env_timeout  180 (seconds)
#    is_ca        Am I the Certificate Authority?  Corresponds to the 'ca'
#                 field.  Default: false
#    master       Configure the [master] section?  Default: false
#    no_warnings  Array of strings from which to ignore warnings; maps to the
#                 'disable_warnings' field.  Empty by default.
#    port         Which port are we talking on?  Defaults to 8140.  Note that
#                 this isn't actually used in the template; we need it for
#                 other classes.
#    reports      Array of reports to send after a puppet run.  Defaults
#                 empty; valid options include 'puppetdb' and 'tagmail'.
#    reporturl    If we're sending an http report, where do we send it?
#                 Defaults to an empty string.
#    run_in_noop  If set, don't make any changes with a puppet run.
#                 Defaults to false.
#    srv_domain
#    server       The main puppet server name.  Required, no default.
#    use_cache    false
#    use_puppetdb If set, turns on puppetdb for storeconfigs.  Defaults
#                 to off.
#
# == Usage
#
#   class { 'puppet::config':
#     env    => 'production',
#     server => 'cms-puppet.fnal.gov'
#   }
#
class puppet::config (
  String[1] $env,
  String[1] $server,
  Boolean $agent        = true,
  Array   $aliases      = [],
  String  $autosign     = '',
  String  $ca_server    = '',
  String  $certname     = $::fqdn,
  String  $config_path  = '/etc/puppetlabs/puppet',
  String  $enc          = '',
  String  $envdir       = '/etc/puppetlabs/code/environments',
  Integer $env_timeout  = 180,
  Array   $extra_agent  = [],
  Array   $extra_main   = [],
  Array   $extra_master = [],
  Boolean $is_ca        = false,
  Boolean $master       = false,
  Array   $no_warnings  = [],
  Integer $port         = 8140,
  Array   $reports      = [],
  String  $reporturl    = '',
  Boolean $run_in_noop  = false,
  Boolean $srv_domain   = false,
  Boolean $use_cache    = false,
  Boolean $use_puppetdb = false
) {
  if count($aliases) > 0 {
    $dns_alt_names = concat ([$::fqdn], $aliases)
  }

  file { 'puppet.conf':
    path    => "${config_path}/puppet.conf",
    content => template('puppet/puppet.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }
}
