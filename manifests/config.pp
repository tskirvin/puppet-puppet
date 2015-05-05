# puppet::config
#
#   Manage /etc/puppet/puppet.conf (or equivalent) for both agent and master
#   use.  It is designed to be configured via hiera.
#
# == Parameters
#
#    agent        Should we configure the puppet agent variables?
#                 Defaults to true.
#    aliases      An array of alternate server names, mapping to dns_alt_names
#                 (along with $certname).  If set, you'll probably have to
#                 handle some manual steps to bring the host up as part of a
#                 pool, involving signing the larger cert; see:
#                      http://docs.puppetlabs.com/guides/scaling_multiple_masters.html#before-running-puppet-agent-or-puppet-master
#    ca_server    Maps to the ca_server field in the [agent] block if
#                 non-empty.  Defaults to an empty string,
#    certname     Maps to the certname field in [main].  Defaults to $::fqdn.
#    config_path  /etc/puppet
#    enc          Are we using an external node classifier?  If so, set
#                 this to the right script name.  Defaults to 'false'.
#    envdir       /etc/puppet/environments
#    env          Default environment; no default, must be set.
#    env_timeout  180 (seconds)
#    is_ca        Am I the Certificate Authority?  Corresponds to the 'ca'
#                 field.  Defaults to false.
#    master       Should we configure the puppet master variables?
#                 Defaults to false.
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
#    server       The main puppet server name.  Required, no default.
#    timeout      How ma
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
  $agent        = true,
  $aliases      = [],
  $ca_server    = '',
  $certname     = $::fqdn,
  $config_path  = '/etc/puppet',
  $enc          = '',
  $env          = '',
  $envdir       = '/etc/puppet/environments',
  $env_timeout  = 180,
  $is_ca        = false,
  $master       = false,
  $no_warnings  = [],
  $port         = 8140,
  $reports      = [],
  $reporturl    = '',
  $run_in_noop  = false,
  $server       = '',
  $timeout      = '',
  $use_puppetdb = false
) {
  validate_array   ($aliases, $no_warnings, $reports)
  validate_bool    ($agent, $is_ca, $master, $run_in_noop, $use_puppetdb)
  validate_string  ($ca_server, $certname, $config_path, $enc, $env,
                    $envdir, $reporturl, $server, $timeout)

  validate_re ($env,    '^\S+$', 'env must be a non-empty word')
  validate_re ($server, '^\S+$', 'server must be a non-empty word')

  # just until we have validate_numeric in stdlib
  # validate_numeric ($env_timeout, $port)
  validate_re ($env_timeout, '^[0-9]+$')
  validate_re ($port, '^[0-9]+$')

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

  file { '/var/log/puppet':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0750'
  }
}
