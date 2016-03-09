require 'spec_helper'
require 'asset_settings/environment_settings'

describe AssetSettings::EnvironmentSettings do
  describe '#img_url_prefix' do
    it 'use different value for production and other environment' do
      expect(AssetSettings::EnvironmentSettings.new(:production).img_url_prefix).to eq('http://assets.vikkr.com/img')
      expect(AssetSettings::EnvironmentSettings.new(:local_assets).img_url_prefix).to eq('/img')
      expect(AssetSettings::EnvironmentSettings.new(:development).img_url_prefix).to eq('/img')
    end
  end

  describe '#[]' do
    subject(:ae) { AssetSettings::EnvironmentSettings.new(:local_assets) }
    it 'can access a new target file and set with a unique source file list' do
      ae['some_file.css'] << 'file_1.css'
      ae['some_file.css'] << 'file_2.css'
      ae['some_file.css'] << 'file_3.css'
      ae['some_file.css'] << 'file_2.css'

      expect(ae.to_hash[:files]['some_file.css'].size).to eq(3)
    end
  end

  describe '#to_hash/#from_hash' do
    subject(:ae) { AssetSettings::EnvironmentSettings.new(:local_assets) }
    it 'restore from a hash' do
      ae['some_file.css'] << 'file_1.css'
      ae['some_file.css'] << 'file_2.css'
      ae['some_file.css'] << 'file_3.css'
      ae['some_file.css'] << 'file_2.css'
      AssetSettings::EnvironmentSettings.new(:local_assets).from_hash(ae.to_hash)
      expect(ae.to_hash[:files]['some_file.css'].size).to eq(3)
    end
  end
end
