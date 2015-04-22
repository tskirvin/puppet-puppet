# puppet::master::mod_passenger
#
#   Configure puppet to communicate to the rest of the world via passenger
#   (the apache-based way of talking to the world).  This includes setting
#
# == Parameters
#
#   is_ca       Am I the CA?  Defaults to either the hiera value of
#               puppet::master::ca (which shares this value), or just false.
#   port        Which network port are we using?  Defaults to 8140.
#   puppetca    What is the puppetca?  Defaults to either the hiera value
#               of puppet::config::ca_server, or undef.  Only used when
#               $is_ca is not set, when we will instead proxy ca requests
#               to the proper ca server.
#   rackdir     Base system directory for the rack configuration; defaults
#               to /usr/share/puppet/rack .
#
# == Prerequisites
#
#    modules/apache (uses mod_headers, mod_proxy, and apache::vhost)
#    modules/passenger
#
# == Usage
#
#    class { 'puppet::master::mod_passenger':
#      is_ca    => false,
#      puppetca => 'puppet'
#    }
#
class puppet::master::mod_passenger (
  $is_ca    = hiera('puppet::config::is_ca', false),
  $port     = 8140,
  $puppetca = hiera('puppet::config::ca_server', ''),
  $rackdir  = '/usr/share/puppet/rack'
) {
  require passenger

  validate_bool   ($is_ca)
  validate_string ($rackdir, $puppetca)
  validate_re     ($port, '^[0-9]+$')

  ensure_resource ('apache::mod', 'headers')

  if $is_ca {
    $ssl_chain = '/var/lib/puppet/ssl/ca/ca_crt.pem'
    $ssl_ca    = '/var/lib/puppet/ssl/ca/ca_crt.pem'
  } else {
    $ssl_chain = '/var/lib/puppet/ssl/certs/ca.pem'
    $ssl_ca    = '/var/lib/puppet/ssl/certs/ca.pem'
    ensure_resource ('apache::mod', 'proxy')
  }

  package { 'rack': ensure => installed, provider => 'gem' }
  ensure_packages (['rake'])

  file { $rackdir: ensure => directory }
  file { "${rackdir}/puppetmasterd":        ensure => directory }
  file { "${rackdir}/puppetmasterd/public": ensure => directory }
  file { "${rackdir}/puppetmasterd/tmp":    ensure => directory }
  file { "${rackdir}/puppetmasterd/config.ru":
    source => '/usr/share/puppet/ext/rack/files/config.ru',
    owner  => 'puppet';
  }


  $docroot = "${rackdir}/puppetmasterd/public/"
  apache::vhost { 'puppet':
    port            => $port,
    docroot         => $docroot,
    directories     => [ {
      path              => $docroot,
      passenger_enabled => 'on'
    } ],
    default_vhost   => true,
    ssl             => true,
    ssl_cert        => "/var/lib/puppet/ssl/certs/${::fqdn}.pem",
    ssl_key         => "/var/lib/puppet/ssl/private_keys/${::fqdn}.pem",
    ssl_chain       => $ssl_chain,
    ssl_ca          => $ssl_ca,
    ssl_crl         => '/var/lib/puppet/ssl/crl.pem',
    options         => [],
    custom_fragment => template('puppet/passenger-fragment.erb'),
  }

  ## We will not be running a standard 'puppetmaster' process on this,
  ## everything is taken care of by apache (which does have to be
  ## started elsewhere).  We'll also set up a notification so that when
  ## puppetmaster would be restarted, we'll notify/poke apache.
  service { 'puppetmaster':
    ensure => stopped,
    enable => false,
    notify => Class['apache::service']
  }
}
