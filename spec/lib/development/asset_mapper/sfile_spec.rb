require 'spec_helper'
require 'development/asset_mapper'

describe AssetMapper::Sfile do
  subject(:sf) { AssetMapper::Sfile.new('js/sample.js') }

  describe '#file_type' do
    it 'return js or css' do
      expect(sf.file_type).to eq('js')
      expect(AssetMapper::Sfile.new('css/some.css').css?).to be_truthy
      expect(sf.js?).to be_truthy
      expect(sf.css?).to be_falsey
    end
  end

  describe '#file_path' do
    it 'should contains assets_dir' do
      expect(sf.file_path).to eq('app/assets/js/sample.js')
    end
  end

  describe '#abs_path' do
    it 'should return absolute path' do
      expect(sf.abs_path).to match(/\A\//)
    end
  end

  describe '#local_url' do
    it 'can used to assets helper in development mode' do
      expect(sf.local_url).to eq('/assets/app/assets/js/sample.js')
    end
  end

  describe '#production_url' do
    it 'should be nil' do
      expect(sf.production_url).to be_nil
    end
  end
end
