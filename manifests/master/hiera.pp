# puppet::master::hiera
#
#   Set up hiera as part of our puppet server.  This includes setting up the
#   the hiera-gpg configuration, but not the appropriate gem.
#
# == Usage
#
#   class { 'puppet::master::hiera': }
#
class puppet::master::hiera ( 
  $config = 'puppet:///modules/puppet/etc/puppet/hiera.yaml'
) {
  include puppet::master

  ensure_packages ( ['hiera'] )

  file { '/etc/puppet/hiera.yaml':
    ensure => present,
    source => $config,
    notify => Service['puppetmaster']
  }
}
