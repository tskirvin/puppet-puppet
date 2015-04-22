require 'spec_helper'

describe 'puppet::master::hiera' do
  let(:facts) {{ 
    :concat_basedir            => '/var/lib/puppet/concat',
    :osfamily                  => 'RedHat', 
    :operatingsystemrelease    => '6.6',
    :operatingsystemmajrelease => '6' 
  }}

  context 'default params check' do
    it 'should include puppet::master' do
      should contain_class('puppet::master')
    end
    it 'should install hiera package' do
      should contain_package('hiera')
    end
    it 'should manage hiera.yaml' do
      should contain_file('/etc/puppet/hiera.yaml').
        that_notifies('Service[puppetmaster]').
        with(:source => 'puppet:///modules/puppet/etc/puppet/hiera.yaml')
    end
  end # default params check

  ### config ###

  context 'alternate config' do
    let(:params) {{ :config => '/foo/bar' }}
    it 'should get hiera.yaml elsewhere' do
      should contain_file('/etc/puppet/hiera.yaml').with(
        :source => '/foo/bar'
      )
    end
  end

  context 'bad config' do
    let(:params) {{ :config => false }}
    it 'should fail' do
      should raise_error(Puppet::Error, /is not a string/)
    end
  end

end # puppet::master::hiera
