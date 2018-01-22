# 
class puppet::puppetserver (
) {
  ensure_packages(['puppetserver'])
  service { 'puppetserver': ensure => running, enable => true }
}
