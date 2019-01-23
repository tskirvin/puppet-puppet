# puppet::syslog
#
#   Sets up syslog to log to (by default) /var/log/puppet.log.  This uses
#   rsyslog (with hooks to add other loggers later if possible), and does
#   not restart the service after the change (which is a problem).
#
class puppet::syslog (
  String $confdir = '/etc/rsyslog.d',
  String $logdir = '/var/log',
  Enum['rsyslog'] $syslog = 'rsyslog',
) {
  validate_absolute_path ($logdir, $confdir)

  ensure_resource('file', $logdir, {
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750'
  })
  $log = "${logdir}/puppet.log"
  file { $log: owner => 'puppet', group => 'puppet', mode => '0660' }

  case $syslog {
    'rsyslog': {
      file { "${confdir}/00-puppet.conf":
        content => "if \$programname == 'puppet-agent' then -${log}\n& stop",
      }
      file { '/etc/logrotate.d/puppet':
        content => template('puppet/logrotate-rsyslog.erb')
      }
    }
    default: { }  # should be taken care of in the enum
  }
}
