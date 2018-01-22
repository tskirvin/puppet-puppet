require 'spec_helper'

describe 'puppet::syslog' do
  let(:facts) {{
    :osfamily => 'RedHat',
    :operatingsystemmajrelease => 6,
    :operatingsystem => 'RedHat'
  }}

  context 'default params check' do
    it 'should log to /var/log/puppet.log' do
      should contain_file('/var/log/puppet.log').with(
        :owner => 'puppet',
        :group => 'puppet',
        :mode  => '0660'
      )
    end # should contain file /var/log/puppet/log

    it 'should create /etc/rsyslog.d/00-puppet' do
      should contain_rsyslog__snippet('00-puppet').
        with_content(/\/var\/log\/puppet.log/)
    end # should create /etc/rsyslog.d/00-puppet

    it 'should create /etc/logrotate.d/puppet' do
      should contain_file('/etc/logrotate.d/puppet').
        with_content(/^\/var\/log\/puppet.log /)
    end # should create /etc/logrotate.d/puppet
  end # default params check

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
