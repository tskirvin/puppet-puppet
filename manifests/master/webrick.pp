# puppet::master::webrick
#
#   Make sure that the default puppetmaster is running, and starts on boot.
#   Nothing much to this one.
#
class puppet::master::webrick () inherits puppet::master {
  service { 'puppetmaster': ensure => running, enable => true }
}
