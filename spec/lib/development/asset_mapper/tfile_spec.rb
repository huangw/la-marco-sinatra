require 'spec_helper'
require 'development/asset_mapper'

describe AssetMapper::Tfile do
  subject(:tf) { AssetMapper::Tfile.new 'application.css' }

  describe '#filename' do
    it 'return a filename with version number' do
      version = Time.now.short
      expect(tf.filename(version)).to eq("application.#{version}.css")
    end
  end

  describe '#file_path' do
    it 'should contains assets_dir' do
      version = Time.now.short
      expect(tf.file_path(version)).to eq("app/assets/min/application.#{version}.css")
    end
  end

  describe '#abs_path' do
    it 'should return absolute path' do
      expect(tf.abs_path('anyversion')).to match(/\A\//)
    end
  end

  describe '#production_url' do
    it 'initialized with nil' do
      expect(tf.production_url).to be_nil
    end

    it 'return with host name' do
      mimic_path = tf.file_path('vmimic')
      AssetSettings[:local_assets][tf.file_id] << mimic_path
      expect(tf.current_file_path).to eq('app/assets/min/application.vmimic.css')
      expect(tf.production_url).to eq('http://assets.vikkr.com/application.vmimic.css')
    end
  end

  describe '#local_url' do
    it 'return with host name' do
      mimic_path = tf.file_path('vmimic')
      AssetSettings[:local_assets][tf.file_id] << mimic_path
      expect(tf.current_file_path).to eq('app/assets/min/application.vmimic.css')
      expect(tf.local_url).to eq('/assets/app/assets/min/application.vmimic.css')
    end
  end
end
