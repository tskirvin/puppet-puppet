require 'spec_helper'

describe 'puppet::puppetserver::java' do
  let(:facts) { { processorcount: 8, memorysize_mb: 16_384 } }

  context 'default params check' do
    it 'set java args' do
      is_expected.to contain_file_line('puppetserver-java_args').with(
        path: '/etc/sysconfig/puppetserver',
        match: 'JAVA_ARGS',
        line: 'JAVA_ARGS="-Xms9g -Xmx12g -XX:+UseG1GC"',
      )
    end
  end # default params check
end
