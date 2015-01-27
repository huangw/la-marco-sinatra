require 'spec_helper'
require 'development/asset_mapper'

describe AssetMapper::Loader do
  subject(:al) { AssetMapper::Loader.new }

  describe 'global defaults setters' do
    it 'can update settings of AssetMapper' do
      al.assets_dir 'public/assets'
      expect(AssetMapper.assets_dir).to eq('public/assets')
    end
  end
end
