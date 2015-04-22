require 'spec_helper'

cron_command = '/usr/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay'
cron_command_noop = cron_command + " --noop"

describe 'puppet::agent' do
  let(:facts) {{ :osfamily => 'RedHat', :operatingsystemmajrelease => '6' }}

  context 'default params check' do
    it 'should include puppet::config' do
      should contain_class('puppet::config')
    end

    it 'should have default service parameters' do
      should contain_service('puppet_agent_daemon').with(
        :name   => 'puppet',
        :enable => true
      )
    end
    it 'should have default cron parameters' do
      should contain_cron('puppet_agent').with(
        :ensure  => 'absent',
        :user    => 'root',
        :command => cron_command,
        :hour    => nil,
        :minute  => nil
      )
    end
    it 'should have default on-boot cron parameters' do
      should contain_cron('puppet_agent_once_at_boot').with(
        :ensure  => 'absent',
        :special => 'reboot',
        :user    => 'root',
        :command => cron_command
      )
    end
  end # default params check

  context 'run as a service' do
    let(:params) {{ :run_method => 'service' }}

    it 'should run as a service' do
      should contain_service('puppet_agent_daemon').with(
        :name   => 'puppet',
        :enable => 'true'
      )
    end # should run as a service

    it 'should not run as a cron job' do
      should contain_cron('puppet_agent').with(:ensure => 'absent')
    end # should not run as a cron job
  end # run as a service

  context 'run as a cronjob' do
    let(:params) {{ :run_method => 'cron' }}
    it 'should not run as a service' do
      should contain_service('puppet_agent_daemon').with(
        :enable => false
      )
    end
    it 'should run as cron' do
      should contain_cron('puppet_agent').with(
        :ensure  => 'present',
        :command => cron_command,
        :user    => 'root',
        :hour    => '*',
        :minute  => [ /\d+/, /\d+/ ]
      )
    end
  end # run as a cronjob

  context 'run_at_boot cronjob' do
    let(:params) {{ :run_at_boot => true }}
    it 'should run as cron at boot' do
      should contain_cron('puppet_agent_once_at_boot').with(
        :ensure  => 'present',
        :command => cron_command,
        :user    => 'root',
        :special => 'reboot'
      )
    end
  end # run_at_boot cronjob

  context 'cron_user' do
    let(:params) {{ :cron_user => 'foo' }}
    it 'should use an alternate user' do
      should contain_cron('puppet_agent').with(:user => 'foo')
    end
  end # cron_user

  context 'run as a noop cronjob' do
    let(:params) {{ :run_method => 'cron', :run_in_noop => true }}
    it 'should run as cron' do
      should contain_cron('puppet_agent').with(
        :command => cron_command_noop
      )
    end
  end # run as a noop cronjob

  context 'run as something invalid' do
    let(:params) {{ :run_method => 'foo' }}
    it 'should fail' do
      should raise_error(Puppet::Error, /run_method is foo; must be 'service' or 'cron'/)
    end
  end # run as something invalid

  context 'logdir check' do
    context 'default values' do
      let(:params) {{ :logdir => '/foo' }}

      it 'should create puppet.log' do
        should contain_file('/foo/puppet.log').with(
          :owner => 'puppet',
          :group => 'puppet',
          :mode  => '0660'
        )
      end # should create puppet.log

      it 'should create /etc/rsyslog.d/00-puppet' do
        should contain_rsyslog__snippet('00-puppet').
          with_content(/\/foo\/puppet.log/)
      end # should create /etc/rsyslog.d/00-puppet

      it 'should create /etc/logrotate.d/puppet' do
        should contain_file('/etc/logrotate.d/puppet').
          with_content(/^\/foo\/puppet.log /)
      end # should create /etc/logrotate.d/puppet

    end

    context 'bad logdir' do
      let(:params) {{ :logdir => '../foobar' }}
      it 'not an absolute path' do
        should raise_error(Puppet::Error, /is not an absolute path/)
      end
    end # bad logdir

  end # logdir check

end # puppet::agent
