require 'spec_helper_acceptance'

describe 'puppet::config class' do
  describe 'running puppet code' do
    pp = <<-EOS
      class { 'puppet::config': server => 'foobar', env => 'testing' }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
