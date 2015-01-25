require 'spec_helper'
require 'assets_config'

describe AssetsConfig do
  subject(:am) { AssetsConfig.new(ENV['APP_ROOT']) }
  describe '#initialize' do
    it 'it add DSL getter/setters' do
      expect(am.root).to eq(ENV['APP_ROOT'])
      expect(am.root('some/where/else')).to eq('some/where/else')
      expect(am.root).to eq('some/where/else')
    end
  end
end
