# Manage /etc/puppetlabs/puppet/puppet.conf for both agent and master
# use.  It is designed to be configured via hiera.
#
# @example Declaring the class (with hiera)
#
#   include puppet::config    # env and server must be set via hiera
#
# @example (Declaring the class (without hiera)
#
#   class { 'puppet::config':
#     env    => 'production',
#     server => 'cms-puppet.fnal.gov'
#   }
#
# @param agent Configure the [agent] section?
# @param aliases Alternative server names - maps to dns_alt_names along with $certname.  If set, you'll probably have to handle some manual steps to sign the certificate; see: <http://docs.puppetlabs.com/guides/scaling_multiple_masters.html#before-running-puppet-agent-or-puppet-master>
# @param autosign Script to run for cert auto-signing; lives in [master].
# @param ca_server lives in [agent] block
# @param certname lives in [main] block
# @param config_path /etc/puppetlabs/puppet
# @param configtimeout lives in [agent]
# @param enc script to run as an external node classifier
# @param env Default environment name.  Required.
# @param envdir Where does your per-environment puppet code live?  Maps to environmentpath in [master]
# @param env_timeout In seconds
# @param extra_agent  Extra settings for [agent]
# @param extra_main   Extra settings for [main]
# @param extra_master Extra settings for [master]
# @param is_ca Am I the Certificate Authority?  Maps to 'ca' field in [master].
# @param log_level Lives in [main]
# @param master Configure the [master] section?  
# @param no_warnings Maps to the 'disable_warnings' field in [main].
# @param port Puppet service port. Note that this isn't actually used in the template; we need it for other classes.
# @param proxy_host
# @param reports Array of reports to send after a puppet run.  Valid options include 'puppetdb' and 'tagmail'.
# @param reporturl URL to send http reports to (if we're sending them)
# @param run_in_noop If set, don't make any changes with a puppet run.
# @param runinterval
# @param runtimeout
# @param server Puppet server name.  Required.
# @param show_diff
# @param splaylimit
# @param srv_domain If set, use the server option as an SRV domain name instead of a puppetserver name.
# @param strict Lives in [master]
# @param trusted_server_facts
# @param use_cache If set, do not set usecacheonfailure=false
# @param use_puppetdb  If set, turns on puppetdb for storeconfigs.
#
class puppet::config (
  String[1] $env,
  String[1] $server,
  Boolean $agent         = true,
  Array   $aliases       = [],
  String  $autosign      = '',
  String  $ca_server     = '',
  String  $certname      = $::fqdn,
  String  $config_path   = '/etc/puppetlabs/puppet',
  Integer $configtimeout = 180,
  String  $enc           = '',
  String  $envdir        = '/etc/puppetlabs/code/environments',
  Integer $env_timeout   = 180,
  Array   $extra_agent   = [],
  Array   $extra_main    = [],
  Array   $extra_master  = [],
  Boolean $is_ca         = false,
  Enum['debug', 'info', 'notice', 'warning', 'err', 'alert', 'emerg', 'crit'] $log_level = 'notice',
  Boolean $master        = false,
  Array[String] $no_warnings = [],
  Integer $port          = 8140,
  Variant[String, Undef] $proxy_host = undef,
  Array   $reports       = [],
  String  $reporturl     = '',
  Boolean $run_in_noop   = false,
  Variant[String, Undef] $runinterval = undef,
  Variant[String, Undef] $runtimeout = undef,
  Boolean $show_diff     = false,
  Variant[String, Undef] $splaylimit = undef,
  Enum['off', 'warning', 'error'] $strict = 'warning',
  Boolean $srv_domain    = false,
  Boolean $trusted_server_facts = true,
  Boolean $use_cache     = false,
  Boolean $use_puppetdb  = false,

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
