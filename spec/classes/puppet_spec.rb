require 'spec_helper'

describe 'puppet' do
  context 'default params check' do
    it 'should include puppet::config' do
      should contain_class('puppet::config')
    end
  end # default params check
end
