require 'spec_helper'

describe 'puppet::config' do
  let(:node) { 'client.invalid' }
  let(:params) { { config_path: '/etc/puppetlabs/puppet' } }

  context 'minimum case' do
    it 'manage puppet.conf' do
      is_expected.to contain_file('puppet.conf').with(
        path:  '/etc/puppetlabs/puppet/puppet.conf',
        owner: 'root',
        group: 'root',
        mode:  '0644',
      )
    end # manage puppet.conf

    it 'default values in puppet.conf' do
      is_expected.to contain_file('puppet.conf')
        .with_content(%r{^\s+environment = baz$})
        .with_content(%r{^\s+server      = server.invalid$})
        .with_content(%r{^\s+certname    = client.invalid$})
    end # default values in puppet.conf
  end # minimum case

  ### agent ###

  context 'agent' do
    context 'on' do
      let(:params) { { 'agent' => true } }

      it 'have an [agent] block' do
        is_expected.to contain_file('puppet.conf').with_content(%r{^\[agent\]$})
      end # have an [agent] block
    end # on

    context 'off' do
      let(:params) { { 'agent' => false } }

      it 'no [agent] block' do
        is_expected.to contain_file('puppet.conf').without_content(%r{^\[agent\]$})
      end # no [agent] block
    end # off
  end # agent

  ### aliases ###

  context 'aliases' do
    context 'exist' do
      let(:params) { { 'aliases' => ['foo', 'bar'] } }

      it 'dns_alt_names entry' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+dns_alt_names\s+=\s+client.invalid, foo, bar$})
      end
    end # exist

    context 'do not exist' do
      let(:params) { { 'aliases' => [] } }

      it 'no dns_alt_names entry' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+dns_alt_names\s+=\s+.*$})
      end
    end # do not exist

    context 'bad aliases' do
      let(:params) { { aliases: 'foo' } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects an Array})
      end
    end # bad aliases
  end # aliases

  ### autosign ###

  context 'autosign' do
    context 'enabled' do
      let(:params) { { master: true, is_ca: true, autosign: 'testing' } }

      it 'enable autosign' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+autosign\s+= testing$})
      end # enable autosign
    end

    context 'disabled' do
      let(:params) { { master: true, is_ca: true, autosign: '' } }

      it 'not enable autosign' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+autosign\s+=.*$})
      end # not enable autosign
    end

    context 'default' do
      let(:params) { { master: true } }

      it 'not enable autosign' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+autosign\s+=.*$})
      end # not enable autosign
    end

    context 'bad' do
      let(:params) { { autosign: false } }

      it 'fail' do
        is_expected.to raise_error(Puppet::Error, %r{expects a String})
      end # fail
    end
  end # autosign

  ### ca_server ###

  context 'ca_server' do
    context 'default' do
      it 'not have a ca_server set' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+ca_server\s+= .*$})
      end # not have a ca_server set
    end # default

    context 'valid' do
      let(:params) { { 'ca_server' => 'ca_server.invalid' } }

      it 'have a ca_server set' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+ca_server\s+= ca_server.invalid$})
      end # have a ca_server set
    end # valid

    context 'empty' do
      let(:params) { { 'ca_server' => '' } }

      it 'not have a ca_server set' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+ca_server\s+= .*$})
      end # not have a ca_server set
    end # empty

    context 'invalid' do
      let(:params) { { 'ca_server' => false } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a String})
      end
    end # invalid
  end # ca_server

  ### certname ###

  context 'certname' do
    context 'valid' do
      let(:params) { { 'certname' => 'foobar' } }

      it 'have a different certname' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+certname    = foobar$})
      end
    end

    context 'invalid' do
      let(:params) { { 'certname' => false } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a String})
      end
    end # invalid
  end # certname

  ### config_path ###

  context 'config_path' do
    context 'default' do
      let(:params) { { master: true } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^# \/etc\/puppetlabs\/puppet\/puppet.conf$})
      end
    end

    context 'valid' do
      let(:params) { { master: true, config_path: '/foo' } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^# \/foo\/puppet.conf$})
      end
    end

    context 'invalid' do
      let(:params) { { master: true, config_path: false } }

      it { is_expected.to raise_error(Puppet::Error, %r{expects a String}) }
    end
  end # config_path

  ### configtimeout ###

  context 'configtimeout' do
    context 'default' do
      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+configtimeout.*$})
      end
    end

    context 'unset' do
      let(:params) { { configtimeout: -1 } }

      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+configtimeout.*$})
      end
    end

    context 'set' do
      let(:params) { { configtimeout: 240 } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+configtimeout = 240$})
      end
    end
  end # configtimeout

  ### enc ###

  context 'enc' do
    context 'enabled' do
      let(:params) { { master: true, enc: 'testing' } }

      it 'enable enc' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+node_terminus\s+= exec$})
          .with_content(%r{^\s+external_nodes\s+= testing$})
      end # enable enc
    end

    context 'disabled' do
      let(:params) { { master: true, enc: '' } }

      it 'not enable enc' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+node_terminus\s+= exec$})
      end # not enable enc
    end

    context 'default' do
      let(:params) { { master: true } }

      it 'not enable enc' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+node_terminus \s+= exec$})
      end # not enable enc
    end

    context 'bad' do
      let(:params) { { enc: false } }

      it 'fail' do
        is_expected.to raise_error(Puppet::Error, %r{expects a String})
      end # fail
    end
  end # enc

  ### env ###

  context 'env' do
    context 'new env' do
      let(:params) { { env: 'foo_bar' } }

      it 'updated environment' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+environment = foo_bar$})
      end # updated environment
    end # new env

    context 'empty env, no agent' do
      let(:params) { { env: '', agent: false } }

      it do
        is_expected.to contain_file('puppet.conf')
      end
    end # empty env, no agent, should succeed

    context 'empty env, yes agent' do
      let(:params) { { env: '', agent: true } }

      it do
        is_expected.to raise_error(%r{When the agent section is configured})
      end
    end # empty env, agent, should fail

    context 'bad env type' do
      let(:params) { { env: ['baz'] } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a String})
      end
    end # bad env type
  end

  ### envdir ###

  context 'envdir' do
    context 'default' do
      let(:params) { { master: true } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+environmentpath\s+= \/etc\/puppetlabs\/code\/environments$})
      end
    end

    context 'valid' do
      let(:params) { { master: true, envdir: '/foo' } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+environmentpath\s+= \/foo$})
      end
    end

    context 'invalid' do
      let(:params) { { master: true, envdir: false } }

      it { is_expected.to raise_error(Puppet::Error, %r{expects a String}) }
    end
  end # envdir

  ### env_timeout ###

  context 'env_timeout' do
    context 'default' do
      let(:params) { { master: true } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+environment_timeout\s+= 180$})
      end
    end

    context 'valid' do
      let(:params) { { master: true, env_timeout: 1 } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+environment_timeout\s+= 1$})
      end
    end

    context 'valid string' do
      let(:params) { { master: true, env_timeout: 'unlimited' } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+environment_timeout\s+= unlimited$})
      end
    end

    context 'invalid string' do
      let(:params) { { master: true, env_timeout: 'foo' } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{must be a})
      end
    end

    context 'invalid non-int' do
      let(:params) { { master: true, env_timeout: 1111.1 } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{must be a})
      end
    end
  end # env_timeout

  ### extra_agent ###

  context 'extra_agent' do
    context 'agent block' do
      let(:params) { { agent: true, extra_agent: ['foo', 'bar'] } }

      it 'add items to agent block' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+foo.*$})
          .with_content(%r{^\s+bar.*$})
      end
    end

    context 'no agent block' do
      let(:params) { { agent: false, extra_agent: ['foo'] } }

      it do
        is_expected.to contain_file('puppet.conf').without_content(%r{^\s+foo$})
      end
    end

    context 'invalid non-Array' do
      let(:params) { { extra_agent: 'foo' } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects an Array})
      end
    end
  end # extra_agent

  ### extra_main ###

  context 'extra_main' do
    context 'main block' do
      let(:params) { { extra_main: ['foo', 'bar'] } }

      it 'add items to main block' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+foo.*$})
          .with_content(%r{^\s+bar.*$})
      end
    end

    context 'invalid non-Array' do
      let(:params) { { extra_main: 'foo' } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects an Array})
      end
    end
  end # extra_main

  ### extra_master ###

  context 'extra_master' do
    context 'master block' do
      let(:params) { { master: true, extra_master: ['foo', 'bar'] } }

      it 'add items to master block' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+foo.*$})
          .with_content(%r{^\s+bar.*$})
      end
    end

    context 'no master block' do
      let(:params) { { master: false, extra_master: ['foo'] } }

      it do
        is_expected.to contain_file('puppet.conf').without_content(%r{^\s+foo$})
      end
    end

    context 'invalid non-Array' do
      let(:params) { { extra_master: 'foo' } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects an Array})
      end
    end
  end # extra_master

  ### is_ca ###

  context 'is_ca' do
    context 'on' do
      let(:params) { { master: true, is_ca: true } }

      it 'set ca = true' do
        is_expected.to contain_file('puppet.conf').with_content(%r{^\s+ca\s+= true$})
      end
    end

    context 'off' do
      let(:params) { { master: true, is_ca: false } }

      it 'set ca = true' do
        is_expected.to contain_file('puppet.conf').with_content(%r{^\s+ca\s+= false$})
      end
    end

    context 'default' do
      let(:params) { { master: true } }

      it 'set ca = true' do
        is_expected.to contain_file('puppet.conf').with_content(%r{^\s+ca\s+= false$})
      end
    end

    context 'bad' do
      let(:params) { { master: true, is_ca: 'fish' } }

      it 'fail' do
        is_expected.to raise_error(Puppet::Error, %r{expects a Boolean})
      end # is_expected.to fail
    end
  end # is_ca

  ### log_level ###

  context 'log_level' do
    ['debug', 'info', 'warning', 'err', 'alert', 'emerg', 'crit'].each do |l|
      context "log_level #{l}" do
        let(:params) { { 'log_level' => l } }

        it "set log_level to #{l}" do
          is_expected.to contain_file('puppet.conf')
            .with_content(%r{^.*log_level\s+=\s+#{l}$})
        end
      end
    end

    context 'log_level foo should fail' do
      let(:params) { { 'log_level' => 'foo' } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{foo})
      end
    end

    context 'log_level notice is default' do
      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^.*log_level.*$})
      end
    end

    context 'log_level notice is default' do
      let(:params) { { 'log_level' => 'notice' } }

      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^.*log_level.*$})
      end
    end
  end

  ### master ###

  context 'master' do
    context 'on' do
      let(:params) { { 'master' => true } }

      it 'have an [master] block' do
        is_expected.to contain_file('puppet.conf').with_content(%r{^\[master\]$})
      end # is_expected.to have an [master] block
    end # on

    context 'off' do
      let(:params) { { 'master' => false } }

      it 'have no [master] block' do
        is_expected.to contain_file('puppet.conf').without_content(%r{^\[master\]$})
      end # is_expected.to have no [master] block
    end # off
  end # master

  ### no_warnings ###

  context 'no_warnings' do
    context 'exist' do
      let(:params) { { 'no_warnings' => ['foo', 'bar'] } }

      it 'have a disable_warnings entry' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+disable_warnings = foo, bar$})
      end
    end # exist

    context 'default' do
      it 'not have a disable_warnings entry' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+disable_warnings =.*$})
      end
    end # do not exist

    context 'do not exist' do
      let(:params) { { 'no_warnings' => [] } }

      it 'not have a disable_warnings entry' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+disable_warnings =.*$})
      end
    end # do not exist

    context 'bad no_warnings' do
      let(:params) { { no_warnings: 'foo' } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects an Array})
      end
    end # bad no_warnings
  end # no_warnings

  ### port ###

  context 'port' do
    context 'invalid string' do
      let(:params) { { port: 'foo' } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects an Integer})
      end
    end

    context 'invalid non-int' do
      let(:params) { { port: '1111.1' } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects an Integer})
      end
    end

    context 'valid' do
      let(:params) { { port: 1111 } }

      it do
        is_expected.to contain_file('puppet.conf')
      end
    end
  end

  ### proxy_host ###
  context 'proxy_host' do
    context 'default' do
      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+http_proxy_host.*$})
      end
    end

    context 'string' do
      let(:params) { { proxy_host: 'foo.bar' } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+http_proxy_host = foo.bar$})
      end
    end

    context 'undef' do
      let(:params) { { proxy_host: :undef } }

      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+http_proxy_host.*$})
      end
    end

    context 'integer' do
      let(:params) { { proxy_host: 1111 } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a value of})
      end
    end
  end # proxy_host

  ### reports ###

  context 'reports' do
    context 'exist' do
      let(:params) { { master: true, reports: ['foo', 'bar'] } }

      it 'have a reports entry' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+reports\s+= foo,bar$})
      end
    end # exist

    context 'default' do
      let(:params) { { master: true } }

      it 'not have a reports entry' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+reports\s+=.*$})
      end
    end # do not exist

    context 'do not exist' do
      let(:params) { { 'reports' => [] } }

      it 'not have a reports entry' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+reports\s+=.*$})
      end
    end # do not exist

    context 'bad reports' do
      let(:params) { { reports: 'foo' } }

      it { is_expected.to raise_error(Puppet::Error, %r{expects an Array}) }
    end # bad reports
  end # reports

  ### reporturl ###

  context 'reporturl' do
    context 'enabled' do
      let(:params) { { master: true, reporturl: 'testing' } }

      it 'enable reporturl' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+reporturl\s+= testing$})
      end # is_expected.to enable reporturl
    end

    context 'disabled' do
      let(:params) { { master: true, reporturl: '' } }

      it 'not enable reporturl' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+reporturl\s+= })
      end # is_expected.to not enable reporturl
    end

    context 'default' do
      let(:params) { { master: true } }

      it 'not enable reporturl' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+reporturl\s+= })
      end # is_expected.to not enable reporturl
    end

    context 'bad' do
      let(:params) { { enc: false } }

      it { is_expected.to raise_error(Puppet::Error, %r{expects a String}) }
    end
  end # reporturl

  ### run_in_noop ###

  context 'run_in_noop' do
    context 'on' do
      let(:params) { { 'run_in_noop' => true } }

      it 'set noop' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s*noop\s+= true$})
      end # is_expected.to not set noop
    end # on

    context 'off' do
      let(:params) { { 'run_in_noop' => false } }

      it 'not set noop' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s*noop\s+= true$})
      end # is_expected.to not set noop
    end

    context 'default' do
      it 'not set noop' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s*noop\s+= true$})
      end # is_expected.to not set noop
    end

    context 'bad' do
      let(:params) { { 'run_in_noop' => 'fish' } }

      it 'fail' do
        is_expected.to raise_error(Puppet::Error, %r{expects a Boolean})
      end # is_expected.to fail
    end
  end # run_in_noop

  ### runinterval ###
  context 'runinterval' do
    context 'default' do
      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+runinterval.*$})
      end
    end

    context 'string' do
      let(:params) { { runinterval: '30m' } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+runinterval\s+= 30m$})
      end
    end

    context 'undef' do
      let(:params) { { runinterval: :undef } }

      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+runinterval.*$})
      end
    end

    context 'integer' do
      let(:params) { { runinterval: 1111 } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a value of})
      end
    end
  end # runinterval

  ### runtimeout ###
  context 'runtimeout' do
    context 'default' do
      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+runtimeout.*$})
      end
    end

    context 'string' do
      let(:params) { { runtimeout: '30m' } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+runtimeout\s+= 30m$})
      end
    end

    context 'undef' do
      let(:params) { { runtimeout: :undef } }

      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+runtimeout.*$})
      end
    end

    context 'integer' do
      let(:params) { { runtimeout: 1111 } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a value of})
      end
    end
  end # runtimeoutt

  ### server ###

  context 'server' do
    context 'new server' do
      let(:params) { { server: 'foo.bar' } }

      it 'have updated server' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+server\s+= foo.bar$})
      end # is_expected.to have updated server
    end # new server

    context 'empty server no agent' do
      let(:params) { { server: '', agent: false } }

      it do
        is_expected.to contain_file('puppet.conf')
      end
    end # empty server no agent, should succeed

    context 'empty server yes agent' do
      let(:params) { { server: '', agent: true } }

      it do
        is_expected.to raise_error(%r{When the agent section is configured})
      end
    end # empty server agent, should fail

    context 'bad server type' do
      let(:params) { { server: ['server.invalid'] } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a String})
      end
    end # bad server type
  end # server

  ### show_diff ###
  context 'show_diff' do
    context 'true' do
      let(:params) { { master: true, show_diff: true } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+show_diff\s+= true$})
      end
    end

    context 'false' do
      let(:params) { { master: true, show_diff: false } }

      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+show_diff.*$})
      end
    end

    context 'default' do
      let(:params) { { master: true } }

      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+show_diff.*$})
      end
    end
  end

  ### splaylimit ###
  context 'splaylimit' do
    context 'default' do
      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+splaylimit.*$})
      end
    end

    context 'string' do
      let(:params) { { splaylimit: '30m' } }

      it do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+splaylimit\s+= 30m$})
      end
    end

    context 'undef' do
      let(:params) { { splaylimit: :undef } }

      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+splaylimit.*$})
      end
    end

    context 'integer' do
      let(:params) { { splaylimit: 1111 } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a value of})
      end
    end
  end # runinterval

  ### srv_domain ###

  context 'srv_domain' do
    context 'true' do
      let(:params) { { server: 'foo.bar', srv_domain: true } }

      it 'set srv_domain instead of server' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+use_srv_records\s+= true$})
          .with_content(%r{^\s+srv_domain\s+= foo.bar$})
          .without_content(%r{^\s+server\s+= foo.bar$})
      end
    end

    context 'false' do
      let(:params) { { server: 'foo.bar', srv_domain: false } }

      it 'set srv_domain instead of server' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+use_srv_records\s+= true$})
          .without_content(%r{^\s+srv_domain\s+= foo.bar$})
          .with_content(%r{^\s+server\s+= foo.bar$})
      end
    end

    context 'default' do
      let(:params) { { server: 'foo.bar' } }

      it 'set srv_domain instead of server' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+use_srv_records\s+= true$})
          .without_content(%r{^\s+srv_domain\s+= foo.bar$})
          .with_content(%r{^\s+server\s+= foo.bar$})
      end
    end

    context 'bad' do
      let(:params) { { server: 'foo.bar', srv_domain: 'hi there' } }

      it 'fail' do
        is_expected.to raise_error(Puppet::Error, %r{expects a Boolean})
      end
    end
  end # srv_domain

  ### strict ###

  context 'strict' do
    ['off', 'error'].each do |l|
      context "strict #{l}" do
        let(:params) { { 'strict' => l, master: true } }

        it "set log_level to #{l}" do
          is_expected.to contain_file('puppet.conf')
            .with_content(%r{^.*strict\s+=\s+#{l}$})
        end
      end
    end

    context 'strict foo should fail' do
      let(:params) { { 'strict' => 'foo', master: true } }

      it do
        is_expected.to raise_error(Puppet::Error, %r{foo})
      end
    end

    context 'strict warning is default' do
      let(:params) { { master: true } }

      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^.*strict = warning$})
      end
    end

    context 'strict warning is default' do
      let(:params) { { 'strict' => 'warning' } }

      it do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^.*strict = warning$})
      end
    end
  end

  ### strict_variables ###

  context 'strict_variables' do
    context 'true' do
      let(:params) { { strict_variables: true } }

      it 'strict_variables' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+strict_variables = true$})
      end
    end

    context 'false' do
      let(:params) { { strict_variables: false } }

      it 'not strict_variables' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+strict_variables = true$})
      end
    end

    context 'default' do
      it 'not strict_variables' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+strict_variables = true$})
      end
    end

    context 'bad' do
      let(:params) { { strict_variables: 'hi there' } }

      it 'fail' do
        is_expected.to raise_error(Puppet::Error, %r{expects a Boolean})
      end
    end
  end # strict_variables

  ### use_cache ###

  context 'use_cache' do
    context 'true' do
      let(:params) { { use_cache: true } }

      it 'use the cache' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+usecacheonfailure = false$})
          .with_content(%r{^\s+usecacheonfailure = true$})
      end
    end

    context 'false' do
      let(:params) { { use_cache: false } }

      it 'not use the cache' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+usecacheonfailure = false$})
          .without_content(%r{^\s+usecacheonfailure = true$})
      end
    end

    context 'default' do
      it 'not use the cache' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+usecacheonfailure = false$})
          .without_content(%r{^\s+usecacheonfailure = true$})
      end
    end

    context 'bad' do
      let(:params) { { use_cache: 'hi there' } }

      it 'fail' do
        is_expected.to raise_error(Puppet::Error, %r{expects a Boolean})
      end
    end
  end # use_cache

  ### use_puppetdb ###

  context 'use_puppetdb' do
    context 'true' do
      let(:params) { { master: true, use_puppetdb: true } }

      it 'enable storeconfigs' do
        is_expected.to contain_file('puppet.conf')
          .with_content(%r{^\s+storeconfigs\s+= true$})
          .with_content(%r{^\s+storeconfigs_backend\s+= puppetdb$})
      end # is_expected.to enable storeconfigs
    end

    context 'false' do
      let(:params) { { master: true, use_puppetdb: false } }

      it 'not enable storeconfigs' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+storeconfigs\s+= true$})
          .without_content(%r{^\s+storeconfigs_backend\s+= puppetdb$})
      end # is_expected.to not enable storeconfigs
    end

    context 'default' do
      let(:params) { { master: true } }

      it 'not enable storeconfigs' do
        is_expected.to contain_file('puppet.conf')
          .without_content(%r{^\s+storeconfigs\s+= true$})
          .without_content(%r{^\s+storeconfigs_backend\s+= puppetdb$})
      end # is_expected.to not enable storeconfigs
    end

    context 'bad' do
      let(:params) { { 'use_puppetdb' => 'fish' } }

      it { is_expected.to raise_error(Puppet::Error, %r{expects a Boolean}) }
    end
  end # use_puppetdb
end # puppet::config
