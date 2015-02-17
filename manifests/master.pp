# puppet::master
#
#   Configures the puppetmaster.
#
#   Most of the actual work is done in puppet::master::*, which define
#   the web interface; see the 'web' parameter for details.
#
# == Parameters
#
#   contact   Array of email addresses that should be contacted with the
#             'tagmail' report type.  Defaults to an empty array.
#   is_ca     Are we the certificate authority?  Defaults to false; this is
#             passed to puppet::master::{webrick|mod_passenger}.
#   hiera     Should we load puppet::master::hiera ?  Default: false.
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
  $contact = [],
  $is_ca   = hiera('puppet::config::is_ca', false),
  $logdir  = false,
  $hiera   = false,
  $web     = 'webrick'
) {
  if ($hiera) { class { 'puppet::master::hiera': } }

  case $web {
    'passenger': { $webclass = 'puppet::master::mod_passenger' }
    'webrick':   { $webclass = 'puppet::master::webrick' }
    default:     { fail ("unknown web class ${web}") }
  }
  class { $webclass: is_ca => $is_ca }

  service { 'puppetmaster': }

  if ($contact) {
    validate_array($contact)
    $email = join($contact, ', ')
    file { '/etc/puppet/tagmail.conf': content => "all: ${email}" }
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
