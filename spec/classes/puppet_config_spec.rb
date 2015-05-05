require 'spec_helper'

describe 'puppet::config' do
  let(:node)  { 'client.invalid' }
  let(:params) {{
    :config_path => '/etc/puppet',
  }}

  context 'minimum case' do
    it 'should manage puppet.conf' do
      should contain_file('puppet.conf').with(
        :path   => '/etc/puppet/puppet.conf',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644'
      )
    end # should manage puppet.conf

    it 'should have default values in puppet.conf' do
      should contain_file('puppet.conf').
        with_content(/^  environment = baz$/).
        with_content(/^  server      = server.invalid$/).
        with_content(/^  certname    = client.invalid$/)
    end # should have default values in puppet.conf

    it 'should manage /var/log/puppet' do
      should contain_file('/var/log/puppet').with({
        :ensure => 'directory',
        :owner  => 'puppet',
        :group  => 'puppet',
        :mode   => '0750'
      })
    end
  end # minimum case

  ### agent ###

  context 'agent' do
    context 'on' do
      let(:params) {{ 'agent' => true }}
      it 'should have an [agent] block' do
        should contain_file('puppet.conf').with_content(/^\[agent\]$/)
      end # should have an [agent] block
    end # on

    context 'off' do
      let(:params) {{ 'agent' => false }}
      it 'should have no [agent] block' do
        should contain_file('puppet.conf').without_content(/^\[agent\]$/)
      end # should have no [agent] block
    end # off
  end # agent

  ### aliases ###

  context 'aliases' do
    context 'exist' do
      let(:params) {{ 'aliases' => [ 'foo', 'bar' ] }}
      it 'should have a dns_alt_names entry' do
        should contain_file('puppet.conf').
          with_content(/^  dns_alt_names = client.invalid, foo, bar$/)
      end
    end # exist

    context 'do not exist' do
      let(:params) {{ 'aliases' => [] }}
      it 'should not have a dns_alt_names entry' do
        should contain_file('puppet.conf').
          without_content(/^  dns_alt_names = .*$/)
      end
    end # do not exist

    context 'bad aliases' do
      let(:params) {{ :aliases => 'foo' }}
      it do
        should raise_error(Puppet::Error, /is not an Array/)
      end
    end # bad aliases
  end # aliases

  ### ca_server ###

  context 'ca_server' do
    context 'default' do
      let(:params) {{ }}
      it 'should not have a ca_server set' do
        should contain_file('puppet.conf').
          without_content(/^  ca_server\s+= .*$/)
      end # should not have a ca_server set
    end # default

    context 'valid' do
      let(:params) {{ 'ca_server' => 'ca_server.invalid' }}
      it 'should have a ca_server set' do
        should contain_file('puppet.conf').
          with_content(/^  ca_server\s+= ca_server.invalid$/)
      end # should have a ca_server set
    end # valid

    context 'empty' do
      let(:params) {{ 'ca_server' => '' }}
      it 'should not have a ca_server set' do
        should contain_file('puppet.conf').
          without_content(/^  ca_server\s+= .*$/)
      end # should not have a ca_server set
    end # empty
 
    context 'invalid' do
      let(:params) {{ 'ca_server' => false }}
      it do
        should raise_error(Puppet::Error, /is not a string/)
      end
    end # invalid
  end # ca_server

  ### certname ###

  context 'certname' do
    context 'valid' do
      let(:params) {{ 'certname' => 'foobar' }}
      it 'should have a different certname' do
        should contain_file('puppet.conf').
          with_content(/^  certname    = foobar$/)
      end
    end

    context 'invalid' do
      let(:params) {{ 'certname' => false }}
      it do
        should raise_error(Puppet::Error, /is not a string/)
      end
    end # invalid
  end # certname

  ### config_path ###

  context 'config_path' do
    context 'default' do
      let(:params) {{ :master => true }}
      it do
        should contain_file('puppet.conf').
          with_content(/^  autosign\s+= \/etc\/puppet\/autosign.conf$/)
      end
    end

    context 'valid' do
      let(:params) {{ :master => true, :config_path => '/foo' }}
      it do
        should contain_file('puppet.conf').
          with_content(/^  autosign\s+= \/foo\/autosign.conf$/)
      end
    end

    context 'invalid' do
      let(:params) {{ :master => true, :config_path => false }}
      it { should raise_error(Puppet::Error, /is not a string/) }
    end
  end # config_path

  ### enc ###
  
  context 'enc' do
    context 'enabled' do
      let(:params) {{ :master => true, :enc => 'testing' }}
      it 'should enable enc' do
        should contain_file('puppet.conf').
          with_content(/^  node_terminus\s+= exec$/).
          with_content(/^  external_nodes\s+= testing$/)
      end # should enable enc
    end

    context 'disabled' do
      let(:params) {{ :master => true, :enc => '' }}
      it 'should not enable enc' do
        should contain_file('puppet.conf').
          without_content(/^  node_terminus\s+= exec$/)
      end # should not enable enc
    end

    context 'default' do
      let(:params) {{ :master => true }}
      it 'should not enable enc' do
        should contain_file('puppet.conf').
          without_content(/^  node_terminus \s+= exec$/)
      end # should not enable enc
    end

    context 'bad' do
      let(:params) {{ :enc => false }}
      it 'should fail' do
        should raise_error(Puppet::Error, /is not a string/)
      end # should fail
    end
  end # enc

  ### env ###

  context 'env' do
    context 'new env' do
      let(:params) {{ :env => 'foo_bar' }}
      it 'should have updated environment' do
        should contain_file('puppet.conf').
          with_content(/^  environment = foo_bar$/)
      end # should have updated environment
    end # new env

    context 'empty env or nothing from hiera' do
      let(:params) {{ 'env' => '' }}
      it do
        should raise_error(Puppet::Error, /must be a non-empty word/)
      end
    end # no env

    context 'bad env type' do
      let(:params) {{ :env => [ 'baz' ] }}
      it do
        should raise_error(Puppet::Error, /is not a string/)
      end
    end # bad env type
  end

  ### envdir ###

  context 'envdir' do
    context 'default' do
      let(:params) {{ :master => true }}
      it do
        should contain_file('puppet.conf').
          with_content(/^  environmentpath\s+= \/etc\/puppet\/environments$/)
      end
    end

    context 'valid' do
      let(:params) {{ :master => true, :envdir => '/foo' }}
      it do
        should contain_file('puppet.conf').
          with_content(/^  environmentpath\s+= \/foo$/)
      end
    end

    context 'invalid' do
      let(:params) {{ :master => true, :envdir => false }}
      it { should raise_error(Puppet::Error, /is not a string/) }
    end
  end # envdir

  ### env_timeout ###
 
  context 'env_timeout' do
    context 'default' do
      let(:params) {{ :master => true }}
      it do
        should contain_file('puppet.conf').
          with_content(/^  environment_timeout\s+= 180$/)
      end
    end

    context 'valid' do
      let(:params) {{ :master => true, :env_timeout => '1' }}
      it do
        should contain_file('puppet.conf').
          with_content(/^  environment_timeout\s+= 1$/)
      end
    end

    context 'invalid string' do
      let(:params) {{ :master => true, :env_timeout => 'foo' }}
      it do
        should raise_error(Puppet::Error, /does not match/)
      end
    end

    context 'invalid non-int' do
      let(:params) {{ :master => true, :env_timeout => '1111.1' }}
      it do
        should raise_error(Puppet::Error, /does not match/)
      end
    end

  end # env_timeout

  ### is_ca ###
 
  context 'is_ca' do
    context 'on' do
      let(:params) {{ :master => true, :is_ca => true }}
      it 'should set ca = true' do
        should contain_file('puppet.conf').with_content(/^  ca\s+= true$/)
      end
    end

    context 'off' do
      let(:params) {{ :master => true, :is_ca => false }}
      it 'should set ca = true' do
        should contain_file('puppet.conf').with_content(/^  ca\s+= false$/)
      end
    end

    context 'default' do
      let(:params) {{ :master => true }}
      it 'should set ca = true' do
        should contain_file('puppet.conf').with_content(/^  ca\s+= false$/)
      end
    end

    context 'bad' do
      let(:params) {{ :master => true, :is_ca => 'fish' }}
      it 'should fail' do
        should raise_error(Puppet::Error, /is not a boolean/)
      end # should fail
    end

  end # is_ca
  
  ### master ###

  context 'master' do
    context 'on' do
      let(:params) {{ 'master' => true }}
      it 'should have an [master] block' do
        should contain_file('puppet.conf').with_content(/^\[master\]$/)
      end # should have an [master] block
    end # on

    context 'off' do
      let(:params) {{ 'master' => false }}
      it 'should have no [master] block' do
        should contain_file('puppet.conf').without_content(/^\[master\]$/)
      end # should have no [master] block
    end # off
  end # master

  ### no_warnings ###

  context 'no_warnings' do
    context 'exist' do
      let(:params) {{ 'no_warnings' => [ 'foo', 'bar' ] }}
      it 'should have a disable_warnings entry' do
        should contain_file('puppet.conf').
          with_content(/^  disable_warnings = foo, bar$/)
      end
    end # exist

    context 'default' do
      let(:params) {{ }}
      it 'should not have a disable_warnings entry' do
        should contain_file('puppet.conf').
          without_content(/^  disable_warnings =.*$/)
      end
    end # do not exist

    context 'do not exist' do
      let(:params) {{ 'no_warnings' => [] }}
      it 'should not have a disable_warnings entry' do
        should contain_file('puppet.conf').
          without_content(/^  disable_warnings =.*$/)
      end
    end # do not exist

    context 'bad no_warnings' do
      let(:params) {{ :no_warnings => 'foo' }}
      it do
        should raise_error(Puppet::Error, /is not an Array/)
      end
    end # bad no_warnings
  end # no_warnings

  ### port ###
 
  context 'port' do
    context 'invalid string' do
      let(:params) {{ :port => 'foo' }}
      it do
        should raise_error(Puppet::Error, /does not match/)
      end
    end

    context 'invalid non-int' do
      let(:params) {{ :port => '1111.1' }}
      it do
        should raise_error(Puppet::Error, /does not match/)
      end
    end

    context 'valid' do
      let(:params) {{ :port => 1111 }}
      it do
        should contain_file('puppet.conf')
      end
    end
  end

  ### reports ###
  
  context 'reports' do
    context 'exist' do
      let(:params) {{ :master => true, :reports => [ 'foo', 'bar' ] }}
      it 'should have a reports entry' do
        should contain_file('puppet.conf').
          with_content(/^  reports\s+= foo,bar$/)
      end
    end # exist

    context 'default' do
      let(:params) {{ :master => true }}
      it 'should not have a reports entry' do
        should contain_file('puppet.conf').
          without_content(/^  reports\s+=.*$/)
      end
    end # do not exist

    context 'do not exist' do
      let(:params) {{ 'reports' => [] }}
      it 'should not have a reports entry' do
        should contain_file('puppet.conf').
          without_content(/^  reports\s+=.*$/)
      end
    end # do not exist

    context 'bad reports' do
      let(:params) {{ :reports => 'foo' }}
      it { should raise_error(Puppet::Error, /is not an Array/) }
    end # bad reports
  end # reports

  ### reporturl ###
  
  context 'reporturl' do
    context 'enabled' do
      let(:params) {{ :master => true, :reporturl => 'testing' }}
      it 'should enable reporturl' do
        should contain_file('puppet.conf').
          with_content(/^  reporturl\s+= testing$/)
      end # should enable reporturl
    end

    context 'disabled' do
      let(:params) {{ :master => true, :reporturl => '' }}
      it 'should not enable reporturl' do
        should contain_file('puppet.conf').
          without_content(/^  reporturl\s+= /)
      end # should not enable reporturl
    end

    context 'default' do
      let(:params) {{ :master => true }}
      it 'should not enable reporturl' do
        should contain_file('puppet.conf').
          without_content(/^  reporturl\s+= /)
      end # should not enable reporturl
    end

    context 'bad' do
      let(:params) {{ :enc => false }}
      it { should raise_error(Puppet::Error, /is not a string/) }
    end

  end # reporturl
  
  ### run_in_noop ###

  context 'run_in_noop' do
    context 'on' do
      let(:params) {{ 'run_in_noop' => true }}
      it 'should set noop' do
        should contain_file('puppet.conf').
          with_content(/^\s*noop\s+= true$/)
      end # should not set noop
    end # on

    context 'off' do
      let(:params) {{ 'run_in_noop' => false }}
      it 'should not set noop' do
        should contain_file('puppet.conf').
          without_content(/^\s*noop\s+= true$/)
      end # should not set noop
    end

    context 'default' do
      let(:params) {{ }}
      it 'should not set noop' do
        should contain_file('puppet.conf').
          without_content(/^\s*noop\s+= true$/)
      end # should not set noop
    end

    context 'bad' do
      let(:params) {{ 'run_in_noop' => 'fish' }}
      it 'should fail' do
        should raise_error(Puppet::Error, /is not a boolean/)
      end # should fail
    end
  end # run_in_noop

  ### server ###

  context 'server' do
    context 'new server' do
      let(:params) {{ :server => 'foo.bar' }}
      it 'should have updated server' do
        should contain_file('puppet.conf').
          with_content(/^  server\s+= foo.bar$/)
      end # should have updated server
    end # new server

    context 'empty server or nothing from hiera' do
      let(:params) {{ 'server' => '' }}
      it do
        should raise_error(Puppet::Error, /must be a non-empty word/)
      end
    end # empty server or nothing from hiera

    context 'bad server type' do
      let(:params) {{ :server => [ 'server.invalid' ] }}
      it do
        should raise_error(Puppet::Error, /is not a string/)
      end
    end # bad server type
  end # server

  ### timeout ###

  context 'timeout' do
    context 'enabled' do
      let(:params) {{ :timeout => 'testing' }}
      it 'should enable timeout' do
        should contain_file('puppet.conf').
          with_content(/^  configtimeout\s+= testing$/)
      end # should enable timeout
    end

    context 'disabled' do
      let(:params) {{ :timeout => '' }}
      it 'should not enable timeout' do
        should contain_file('puppet.conf').
          without_content(/^  configtimeout\s+= /)
      end # should not enable timeout
    end

    context 'default' do
      let(:params) {{ }}
      it 'should not enable timeout' do
        should contain_file('puppet.conf').
          without_content(/^  configtimeout\s+= /)
      end # should not enable timeout
    end

    context 'bad' do
      let(:params) {{ :timeout => false }}
      it { should raise_error(Puppet::Error, /is not a string/) }
    end
  end # timeout

  ### use_puppetdb ###
  
  context 'use_puppetdb' do
    context 'true' do
      let(:params) {{ :master => true, :use_puppetdb => true }}
      it 'should enable storeconfigs' do
        should contain_file('puppet.conf').
          with_content(/^  storeconfigs\s+= true$/).
          with_content(/^  storeconfigs_backend\s+= puppetdb$/)
      end # should enable storeconfigs
    end

    context 'false' do
      let(:params) {{ :master => true, :use_puppetdb => false }}
      it 'should not enable storeconfigs' do
        should contain_file('puppet.conf').
          without_content(/^  storeconfigs\s+= true$/).
          without_content(/^  storeconfigs_backend\s+= puppetdb$/)
      end # should not enable storeconfigs
    end

    context 'default' do
      let(:params) {{ :master => true }}
      it 'should not enable storeconfigs' do
        should contain_file('puppet.conf').
          without_content(/^  storeconfigs\s+= true$/).
          without_content(/^  storeconfigs_backend\s+= puppetdb$/)
      end # should not enable storeconfigs
    end

    context 'bad' do
      let(:params) {{ 'use_puppetdb' => 'fish' }}
      it { should raise_error(Puppet::Error, /is not a boolean/) }
    end
  end # use_puppetdb

end # puppet::config
