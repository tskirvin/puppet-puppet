# Configure the puppetserver process's java bits
#
# @param java_args
# @param java_memory_min_percentage
# @param java_memory_max_percentage
#
class puppet::puppetserver::java (
  String $java_args = '-XX:+UseG1GC',
  Numeric $java_memory_min_percentage = 60,
  Numeric $java_memory_max_percentage = 80
) inherits puppet::puppetserver {
  tag 'puppetserver'

  $sysconf_path = $puppet::puppetserver::sysconf_path

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
}
