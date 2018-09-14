# Configure the puppetserver process.  This includes managing the 
# certificate-authority related bits, as described here: <https://docs.puppetlabs.com/puppetserver/latest/external_ca_configuration.html>
#
# @param config_path
# @param sysconf_path
# @param java_args
# @param java_memory_min_percentage
# @param java_memory_max_percentage
# @param max_instances
# @param ssl_path
#
class puppet::puppetserver (
  String $config_path = '/etc/puppetlabs',
  String $sysconf_path = '/etc/sysconfig',
  String $java_args = '-XX:+UseG1GC',
  Numeric $java_memory_min_percentage = 60,
  Numeric $java_memory_max_percentage = 80,
  Integer $max_instances = $::processorcount,
  String $ssl_path = 'ssl'
) inherits puppet::config {
  tag 'puppetserver'

  $is_ca = $puppet::config::is_ca

  ensure_packages(['puppetserver'])
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

  # generate the JAVA_ARGS argument - Xms, Xmx
  $memory = $::memorysize_mb / 1024
  $xms = $memory * $java_memory_min_percentage / 100
  $xmx = $memory * $java_memory_max_percentage / 100

  $jargs_0 = inline_template('-Xms<%= format("%.0f", @xms) %>g')
  $jargs_1 = inline_template('-Xmx<%= format("%.0f", @xmx) %>g')
  $line = "JAVA_ARGS=\"${jargs_0} ${jargs_1} ${java_args}\""

  file_line { 'puppetserver-java_args':
    path   => "${sysconf_path}/puppetserver",
    line   => $line,
    match  => 'JAVA_ARGS',
    notify => Service['puppetserver']
  }

  file_line { 'puppetserver-max-active-instances':
    path   => "${config_path}/puppetserver/conf.d/puppetserver.conf",
    line   => "    max-active-instances: ${max_instances}",
    match  => 'max-active-instances',
    notify => Service['puppetserver']
  }
}
