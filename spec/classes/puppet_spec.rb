require 'spec_helper'

describe 'puppet' do
  context 'default params check' do
    it 'include puppet::config' do
      is_expected.to contain_class('puppet::config')
    end
  end # default params check
end
