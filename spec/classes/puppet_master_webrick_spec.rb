require 'spec_helper'

describe 'puppet::master::webrick' do
  let(:facts) {{ 
    :concat_basedir            => '/var/lib/puppet/concat',
    :osfamily                  => 'RedHat', 
    :operatingsystemrelease    => '6.6',
    :operatingsystemmajrelease => '6' 
  }}

  context 'default params check' do
    it 'should define the puppetmaster service' do
      should contain_service('puppetmaster').with(
        :ensure => 'running',
        :enable => true
      )
    end
  end # default params check

end # puppet::agent
