# puppet::master
#
#   Configures the puppetmaster.
#
#   Most of the actual work is done in puppet::master::*, which define
#   the web interface; see the 'web' parameter for details.
#
# == Parameters
#
#   is_ca     Are we the certificate authority?  Defaults to false; this is
#             passed to puppet::master::{webrick|mod_passenger}.
#   logdir    Set up logging, pointing at this log directory.  Any logs
#             go to ${logdir}/puppetmaster.log, in addition to syslog.
#             Defaults to 'false', so no additional logging will happen.
#   web       Which web server are we going to use to share the content with
#             our clients?  Possible values:
#
#               webrick    puppet::master::webrick       DEFAULT
#               passenger  puppet::master::mod_passenger
#
# == Usage
#
#   class { 'puppet::master': hiera => true, web => 'passenger' }
#
class puppet::master (
  $is_ca  = hiera('puppet::config::is_ca', false),
  $logdir = '',
  $web    = 'webrick'
) {
  validate_bool ($is_ca)
  validate_string ($logdir, $web)

  case $web {
    'passenger': { require 'puppet::master::mod_passenger' }
    'webrick':   { require 'puppet::master::webrick' }
    default:     { fail ("unknown web class ${web}") }
  }

  if ($logdir) {
    validate_absolute_path ($logdir)
    rsyslog::snippet { '00-puppetmaster':
      ensure  => present,
      content => "if \$programname == 'puppet-master' then -${logdir}/puppetmaster.log\n& ~"
    }
    file { "${logdir}/puppetmaster.log":
      owner => 'puppet',
      group => 'puppet',
      mode  => '0660'
    }
    file { '/etc/logrotate.d/puppetmaster':
      ensure  => present,
      content => template('puppet/logrotate-puppetmaster.erb')
    }
  }
}
