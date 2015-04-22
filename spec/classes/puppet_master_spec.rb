require 'spec_helper'

describe 'puppet::master' do
  let(:facts) {{ 
    :concat_basedir            => '/var/lib/puppet/concat',
    :osfamily                  => 'RedHat', 
    :operatingsystemrelease    => '6.6',
    :operatingsystemmajrelease => '6' 
  }}

  context 'default params check' do
    it 'should include puppet::master::webrick' do
      should contain_class('puppet::master::webrick')
    end
    it 'should define the puppetmaster service' do
      should contain_service('puppetmaster')
    end
  end # default params check

  ### is_ca ### 

  context 'is_ca should fail' do
    let(:params) {{ :is_ca => 'foo' }}
    it 'should fail' do
      should raise_error(Puppet::Error, /is not a boolean/)
    end
  end
  
  ### web ### 
  
  context 'web as webrick' do
    let(:params) {{ :web => 'webrick' }}
    it 'should include puppet::master::webrick' do
      should contain_class('puppet::master::webrick')
    end
  end # web as webrick

  context 'web as passenger' do
    let(:params) {{ :web => 'passenger' }}
    it 'should include puppet::master::mod_passenger' do
      should contain_class('puppet::master::mod_passenger')
    end
  end # web as passenger

  context 'web as something invalid' do
    let(:params) {{ :web => 'foo' }}
    it 'should fail' do
      should raise_error(Puppet::Error, /unknown web class foo/)
    end
  end # web as something invalid

  ### logdir ###

  context 'logdir check' do
    context 'default values' do
      let(:params) {{ :logdir => '/foo' }}

      it 'should create puppetmaster.log' do
        should contain_file('/foo/puppetmaster.log').with(
          :owner => 'puppet',
          :group => 'puppet',
          :mode  => '0660'
        )
      end # should create puppet.log

      it 'should create /etc/rsyslog.d/00-puppetmaster' do
        should contain_rsyslog__snippet('00-puppetmaster').
          with_content(/\/foo\/puppetmaster.log/)
      end # should create /etc/rsyslog.d/00-puppetmaster

      it 'should create /etc/logrotate.d/puppetmaster' do
        should contain_file('/etc/logrotate.d/puppetmaster').
          with_content(/^\/foo\/masterhttp.log \/foo\/puppetmaster.log /)
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
