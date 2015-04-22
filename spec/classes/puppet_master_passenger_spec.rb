require 'spec_helper'

describe 'puppet::master::mod_passenger' do
  let(:facts) {{ 
    :concat_basedir            => '/var/lib/puppet/concat',
    :osfamily                  => 'RedHat', 
    :operatingsystemrelease    => '6.6',
    :operatingsystemmajrelease => '6' 
  }}
  let(:node)  { 'foobar2.invalid' }

  context 'default params check' do
    it 'should install rack package' do
      should contain_package('rack')
    end
    it 'should install rake package' do
      should contain_package('rake')
    end
    it 'should clone config.ru' do
      should contain_file('/usr/share/puppet/rack/puppetmasterd/config.ru').
        with(
          :source => '/usr/share/puppet/ext/rack/files/config.ru',
          :owner  => 'puppet'
        )
    end

    it 'should configure apache' do
      should contain_apache__vhost('puppet').with(
        :port      => 8140,
        :docroot   => '/usr/share/puppet/rack/puppetmasterd/public/',
        :default_vhost => true,
        :ssl       => true,
        :ssl_cert  => '/var/lib/puppet/ssl/certs/foobar2.invalid.pem',
        :ssl_key   => '/var/lib/puppet/ssl/private_keys/foobar2.invalid.pem',
        :ssl_chain => '/var/lib/puppet/ssl/certs/ca.pem',
        :ssl_ca    => '/var/lib/puppet/ssl/certs/ca.pem',
        :ssl_crl   => '/var/lib/puppet/ssl/crl.pem',
        :options   => [],
        :custom_fragment => /RackAutoDetect On/
      )
      should contain_apache__mod('headers')
    end # should configure apache

    it 'should turn off puppetmaster' do
      should contain_service('puppetmaster').with(
        :ensure => 'stopped', 
        :enable => false
      ).that_notifies('Class[apache::service]')
    end
  end # default params check

  ### is_ca, port, puppetca ###

  context 'is_ca is on' do
    let(:params) {{ :is_ca => true }}
    it 'should configure apache accordingly' do
      should contain_apache__vhost('puppet').with(
        :ssl_chain => '/var/lib/puppet/ssl/ca/ca_crt.pem',
        :ssl_ca    => '/var/lib/puppet/ssl/ca/ca_crt.pem'
      )
      should_not contain_apache__vhost('puppet').with(
        :custom_fragment => /^  SSLProxyEngine/
      )
      should_not contain_apache__vhost('puppet').with(
        :custom_fragment => /^  ProxyPassMatch/
      )
    end 
  end # is_ca is on

  context 'is_ca is off, puppetca is set' do
    let(:params) {{ :is_ca => false, :puppetca => 'foo' }}
    it 'should configure apache accordingly' do
      should contain_apache__vhost('puppet').with(
        :custom_fragment => /^  SSLProxyEngine/
      )
      should contain_apache__vhost('puppet').with(
        :custom_fragment => /^  ProxyPassMatch.*https:\/\/foo:8140\/\$1$/
      )
      should contain_apache__mod('proxy')
    end 
  end

  context 'is_ca is off, puppetca is set, port is set' do
    let(:params) {{ :is_ca => false, :puppetca => 'foo', :port => '12345' }}
    it 'should configure apache accordingly' do
      should contain_apache__vhost('puppet').with(
        :custom_fragment => /^  SSLProxyEngine/
      )
      should contain_apache__vhost('puppet').with(
        :custom_fragment => /^  ProxyPassMatch.*https:\/\/foo:12345\/\$1$/
      )
      should contain_apache__mod('proxy')
    end 
  end

  context 'is_ca is off, no puppetca' do
    let(:params) {{ :is_ca => false }}
    it 'should configure apache accordingly' do
      should_not contain_apache__vhost('puppet').with(
        :custom_fragment => /^  SSLProxyEngine/
      )
      should_not contain_apache__vhost('puppet').with(
        :custom_fragment => /^  ProxyPassMatch/
      )
    end
  end

  context 'invalid is_ca' do
    let(:params) {{ :is_ca => 'foo' }}
    it do
      should raise_error(Puppet::Error, /is not a boolean/)
    end
  end # invalid is_ca

  ### rackdir ###

  context 'rackdir override' do
    let(:params) {{ :rackdir => '/foobar' }}
    it 'should clone config.ru' do
      should contain_file('/foobar/puppetmasterd/config.ru')
    end
  end # rackdir override

  context 'invalid rackdir' do
    let(:params) {{ :rackdir => false }}
    it do
      should raise_error(Puppet::Error, /is not a string/)
    end
  end # invalid rackdir
  
  ## port
  ## puppetca

end # puppet::master::mod_passenger
