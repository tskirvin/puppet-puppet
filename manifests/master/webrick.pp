# puppet::master::webrick
#
#   Make sure that the default puppetmaster is running, and
#   starts on boot.  Nothing much to this one.
#
class puppet::master::webrick ($is_ca = false) inherits puppet::master {
  ensure_resource ('class', 'puppet::master')
  Service['puppetmaster'] { ensure => running, enable => true }
}
