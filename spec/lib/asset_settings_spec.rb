require 'spec_helper'
require 'asset_settings'

describe AssetSettings do
  describe '#[]' do
    it 'get an instance of EnvironmentSettings with default' do
      expect(AssetSettings[:production]).to be_instance_of(AssetSettings::EnvironmentSettings)
      expect(AssetSettings[:production].img_dir).to eq('app/assets/img')
      expect(AssetSettings[:production]['application222.css']).to be_empty
      AssetSettings[:production]['application222.css'] << 'file_one.css'
      AssetSettings[:production]['application222.css'] << 'file_two.css'
      expect(AssetSettings[:production]['application222.css'].size).to eq(2)
    end
  end

  describe '#to_hash' do
    it 'contains all environments' do
      expect(AssetSettings.to_hash.keys).to eq(AssetSettings.environments)
    end
  end
end
