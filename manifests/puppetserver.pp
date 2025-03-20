# Configure the puppetserver process.  This includes managing the 
# certificate-authority related bits, as described here: <https://docs.puppetlabs.com/puppetserver/latest/external_ca_configuration.html>
#
# @param config_path
# @param sysconf_path
# @param max_instances
# @param ssl_path
# @param package_name
#
class puppet::puppetserver (
  String $config_path = '/etc/puppetlabs',
  String $sysconf_path = '/etc/sysconfig',
  Integer $max_instances = $facts['processors']['count'],
  String $ssl_path = 'ssl',
  String $package_name = 'puppetserver'
) inherits puppet::config {
  tag 'puppetserver'

  $is_ca = $puppet::config::is_ca

  ensure_packages([$package_name])
  service { 'puppetserver': ensure => running, enable => true }

  $line_ca_enable  = 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service'
  $line_ca_disable = 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service'

  if $is_ca {
    $set_1 = $line_ca_enable
    $set_2 = "#${line_ca_disable}"
  } else {
    $set_1 = "#${line_ca_enable}"
    $set_2 = $line_ca_disable
  }

  $bootstrap =  "${config_path}/puppetserver/services.d/ca.cfg"

  file_line { 'fix-bootstrap-1':
    path   => $bootstrap,
    line   => $set_1,
    match  => $line_ca_enable,
    notify => Service['puppetserver']
  }

  file_line { 'fix-bootstrap-2':
    path   => $bootstrap,
    line   => $set_2,
    match  => $line_ca_disable,
    notify => Service['puppetserver']
  }

  file { "${config_path}/puppetserver/conf.d/webserver.conf":
    content => template('puppet/puppetserver-webserver.erb'),
    notify  => Service['puppetserver']
  }

  file_line { 'puppetserver-max-active-instances':
    path   => "${config_path}/puppetserver/conf.d/puppetserver.conf",
    line   => "    max-active-instances: ${max_instances}",
    match  => 'max-active-instances',
    notify => Service['puppetserver']
  }
}
