require 'spec_helper'
require 'devtools/asset_mapper'

describe AssetMapper do
  describe 'singleton setters' do
    it 'initialized with default values' do
      expect(AssetMapper.root).to eq(ENV['APP_ROOT'])
      expect(AssetMapper.assets_dir).to eq('app/assets')
    end

    it 'can set to other value' do
      AssetMapper.vendor_dir 'public/vendor'
      expect(AssetMapper.vendor_dir).to eq('public/vendor')
    end
  end
end
