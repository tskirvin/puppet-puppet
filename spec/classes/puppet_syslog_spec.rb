require 'spec_helper'

describe 'puppet::syslog' do
  let(:facts) { { osfamily: 'RedHat', operatingsystemmajrelease: 6, operatingsystem: 'RedHat' } }

  context 'default params check' do
    it 'log to /var/log/puppet.log' do
      is_expected.to contain_file('/var/log/puppet.log').with(
        owner: 'puppet',
        group: 'puppet',
        mode: '0660',
      )
    end # contain file /var/log/puppet/log

    it 'create /etc/rsyslog.d/00-puppet' do
      is_expected.to contain_rsyslog__snippet('00-puppet')
        .with_content(%r{\/var\/log\/puppet.log})
    end # create /etc/rsyslog.d/00-puppet

    it 'create /etc/logrotate.d/puppet' do
      is_expected.to contain_file('/etc/logrotate.d/puppet')
        .with_content(%r{^\/var\/log\/puppet.log})
    end # create /etc/logrotate.d/puppet
  end # default params check

  context 'logdir check' do
    context 'default values' do
      let(:params) { { logdir: '/foo' } }

      it 'create puppet.log' do
        is_expected.to contain_file('/foo/puppet.log').with(
          owner: 'puppet',
          group: 'puppet',
          mode: '0660',
        )
      end # create puppet.log

      it 'create /etc/rsyslog.d/00-puppet' do
        is_expected.to contain_rsyslog__snippet('00-puppet')
          .with_content(%r{\/foo\/puppet.log})
      end # create /etc/rsyslog.d/00-puppet

      it 'create /etc/logrotate.d/puppet' do
        is_expected.to contain_file('/etc/logrotate.d/puppet')
          .with_content(%r{^\/foo\/puppet.log})
      end # create /etc/logrotate.d/puppet
    end

    context 'bad logdir' do
      let(:params) { { logdir: '../foobar' } }

      it 'not an absolute path' do
        is_expected.to raise_error(Puppet::Error, %r{is not an absolute path})
      end
    end # bad logdir
  end # logdir check
end # puppet::syslog
