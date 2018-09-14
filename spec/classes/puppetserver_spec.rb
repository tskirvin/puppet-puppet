require 'spec_helper'

describe 'puppet::puppetserver' do
  let(:facts) { { :processorcount => 32, :memorysize_mb => 16384 } }

  context 'default params check' do
    it 'run puppetserver service' do
      should contain_service('puppetserver').with(
        :name   => 'puppetserver',
        :enable => 'true',
        :ensure => 'running'
      )
    end
  end # default params check
end
