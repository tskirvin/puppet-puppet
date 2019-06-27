require 'spec_helper'

describe 'puppet::puppetserver::java' do
  let(:facts) { { processorcount: 8, memorysize_mb: 16_384 } }

  context 'default params check' do
    it 'set java args' do
      is_expected.to contain_file_line('puppetserver-java_args').with(
        path: '/etc/sysconfig/puppetserver',
        match: '^JAVA_ARGS=',
        line: 'JAVA_ARGS="-Xms9g -Xmx12g -XX:ReservedCodeCacheSize=1g -XX:+UseG1GC"',
      )
    end
  end # default params check

  context 'reserved_code_cache=none' do
    let(:params) { { reserved_code_cache: 'none' } }

    it 'set java args' do
      is_expected.to contain_file_line('puppetserver-java_args').with(
        line: 'JAVA_ARGS="-Xms9g -Xmx12g  -XX:+UseG1GC"',
      )
    end
  end # reserve_code_cache=none

  context 'reserved_code_cache=768m' do   # arbitrary text
    let(:params) { { reserved_code_cache: '768m' } }
    it 'set java args' do
      is_expected.to contain_file_line('puppetserver-java_args').with(
        line: 'JAVA_ARGS="-Xms9g -Xmx12g -XX:ReservedCodeCacheSize=768m -XX:+UseG1GC"'
      )
    end
  end # reserved_code_cache=768m

  context 'instances=2' do  # should be 512m
    let(:params) { { reserved_code_cache: 'auto', instances: 2 } }
    it 'set java args' do
      is_expected.to contain_file_line('puppetserver-java_args').with(
        line: 'JAVA_ARGS="-Xms9g -Xmx12g -XX:ReservedCodeCacheSize=512m -XX:+UseG1GC"'
      )
    end
  end # instances=2 check

  context 'instances=4' do  # should be 512m (again)
    let(:params) { { reserved_code_cache: 'auto', instances: 4 } }
    it 'set java args' do
      is_expected.to contain_file_line('puppetserver-java_args').with(
        line: 'JAVA_ARGS="-Xms9g -Xmx12g -XX:ReservedCodeCacheSize=512m -XX:+UseG1GC"'
      )
    end
  end # instances=4 check

  context 'instances=8' do  # should be 1g
    let(:params) { { reserved_code_cache: 'auto', instances: 8 } }
    it 'set java args' do
      is_expected.to contain_file_line('puppetserver-java_args').with(
        line: 'JAVA_ARGS="-Xms9g -Xmx12g -XX:ReservedCodeCacheSize=1g -XX:+UseG1GC"'
      )
    end
  end # instances=8 check

  context 'instances=16' do  # should be 2g
    let(:params) { { reserved_code_cache: 'auto', instances: 16 } }
    it 'set java args' do
      is_expected.to contain_file_line('puppetserver-java_args').with(
        line: 'JAVA_ARGS="-Xms9g -Xmx12g -XX:ReservedCodeCacheSize=2g -XX:+UseG1GC"'
      )
    end
  end # instances=16 check


end
