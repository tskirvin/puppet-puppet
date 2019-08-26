# Configure the puppetserver process's java bits.
#
# The reserved code cache bit is from here, and matches the recommendations:
#
#   https://puppet.com/docs/puppetserver/6.1/known_issues.html
#
# @param instances
# @param java_args
# @param java_memory_min_percentage
# @param java_memory_max_percentage
# @param reserved_code_cache
#
class puppet::puppetserver::java (
  Integer $instances = $::puppet::puppetserver::max_instances,
  String $java_args = '-XX:+UseG1GC',
  String $reserved_code_cache = 'auto',
) inherits puppet::puppetserver {
  tag 'puppetserver'

  $sysconf_path = $puppet::puppetserver::sysconf_path

  # https://puppet.com/docs/puppetserver/6.1/known_issues.html
  # We need to set ReservedCodeCache in most cases, apparently.
  case $reserved_code_cache {
    'auto': {
      case true {
        $instances <= 6:  { $reserved = '512m' }
        $instances <= 12: { $reserved = '1g' }
        default:          { $reserved = '2g' }
      }
      $java_reserve = "-XX:ReservedCodeCacheSize=${reserved}"
    }
    'none': { $java_reserve = '' }
    default: {
      $java_reserve = "-XX:ReservedCodeCacheSize=${reserved_code_cache}"
    }
  }

  $line = "JAVA_ARGS=\"${java_reserve} ${java_args}\""

  file_line { 'puppetserver-java_args':
    path   => "${sysconf_path}/puppetserver",
    line   => $line,
    match  => '^JAVA_ARGS=',
    notify => Service['puppetserver']
  }
}
