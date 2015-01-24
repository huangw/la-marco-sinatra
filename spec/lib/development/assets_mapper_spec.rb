require 'spec_helper'
require 'development/assets_mapper'

describe AssetsMapper::Loader do
  subject(:am) { AssetsMapper::Loader.new(ENV['APP_ROOT']) }
  describe '#initialize' do
    it 'it add DSL getter/setters' do
      expect(am.root).to eq(ENV['APP_ROOT'])
      expect(am.root('some/where/else')).to eq('some/where/else')
      expect(am.root).to eq('some/where/else')
    end
  end
end
