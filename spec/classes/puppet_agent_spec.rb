require 'spec_helper'

cron_command = '/opt/puppetlabs/bin/puppet agent -t'
cron_command_noop = cron_command + ' --noop'

describe 'puppet::agent' do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystemmajrelease => '6' } }

  context 'default params check' do
    it 'include puppet::config' do
      should contain_class('puppet::config')
    end

    it 'have default service parameters' do
      should contain_service('puppet_agent_daemon').with(
        :name   => 'puppet',
        :enable => false
      )
    end
    it 'have default cron parameters' do
      should contain_cron('puppet_agent').with(
        :ensure  => 'present',
        :user    => 'root',
        :command => cron_command
      )
    end
    it 'have default on-boot cron parameters' do
      should contain_cron('puppet_agent_once_at_boot').with(
        :ensure  => 'present',
        :special => 'reboot',
        :user    => 'root',
        :command => cron_command
      )
    end
  end # default params check

  context 'run as a service' do
    let(:params) { { :run_method => 'service' } }

    it 'run as a service' do
      should contain_service('puppet_agent_daemon').with(
        :name   => 'puppet',
        :enable => 'true'
      )
    end # run as a service

    it 'not run as a cron job' do
      should contain_cron('puppet_agent').with(:ensure => 'absent')
    end # not run as a cron job
  end # run as a service

  context 'run as a cronjob' do
    let(:params) { { :run_method => 'cron' } }

    it 'not run as a service' do
      should contain_service('puppet_agent_daemon').with(
        :enable => false
      )
    end
    it 'run as cron' do
      should contain_cron('puppet_agent').with(
        :ensure  => 'present',
        :command => cron_command,
        :user    => 'root',
        :hour    => ['*'],
        :minute  => [/\d+/, /\d+/]
      )
    end
  end # run as a cronjob

  context 'run_at_boot cronjob' do
    let(:params) { { :cron_run_at_boot => true } }

    it 'run as cron at boot' do
      should contain_cron('puppet_agent_once_at_boot').with(
        :ensure  => 'present',
        :command => cron_command,
        :user    => 'root',
        :special => 'reboot'
      )
    end
  end # run_at_boot cronjob

  context 'cron_user' do
    let(:params) { { :cron_user => 'foo' } }

    it 'use an alternate user' do
      should contain_cron('puppet_agent').with(:user => 'foo')
    end
  end # cron_user

  context 'run as a noop cronjob' do
    let(:params) { { :run_method => 'cron', :cron_run_in_noop => true } }

    it 'run as cron' do
      should contain_cron('puppet_agent').with(
        :command => cron_command_noop
      )
    end
  end # run as a noop cronjob

  context 'run as something invalid' do
    let(:params) { { :run_method => 'foo' } }

    it 'fail' do
      should raise_error(Puppet::Error, /expects a match for Enum/)
    end
  end # run as something invalid

end # puppet::agent
