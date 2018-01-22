require 'spec_helper'

describe 'puppet::puppetserver' do
  context 'default params check' do
    it 'should run puppetserver service' do
      should contain_service('puppetserver').with(
        :name   => 'puppetserver', 
        :enable => 'true', 
        :ensure => 'running'
      )
    end
  end # default params check
end
