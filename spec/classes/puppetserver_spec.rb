require 'spec_helper'

describe 'puppet::puppetserver' do
  let(:facts) { { processorcount: 32, memorysize_mb: 16_384 } }

  context 'default params check' do
    it 'run puppetserver service' do
      is_expected.to contain_service('puppetserver').with(
        name: 'puppetserver',
        enable: 'true',
        ensure: 'running',
      )
    end
    it 'webserver configuration' do
      is_expected.to contain_file('/etc/puppetlabs/puppetserver/conf.d/webserver.conf')
    end
  end # default params check
end
