# puppet::syslog
#
#   Sets up syslog.
#
class puppet::syslog (
  String $logdir = '/var/log'
) {
  validate_absolute_path ($logdir)

  file { $logdir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750'
  }
  $log = "${logdir}/puppet.log"
  file { $log: owner => 'puppet', group => 'puppet', mode => '0660' }

  rsyslog::snippet { '00-puppet':
    content => "if \$programname == 'puppet-agent' then -${log}\n& stop"
  }

  file { '/etc/logrotate.d/puppet':
    content => template('puppet/logrotate-puppet.erb')
  }
}
