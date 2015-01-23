require 'spec_helper'
require 'development/i18n_updator'

describe I18nUpdator do
  describe '.fetch_view_keys' do
    it 'fetch keys in tt :symbolic form' do
      expect(I18nUpdator.fetch_view_keys(['tt :name'])).to include('name')
      expect(I18nUpdator.fetch_view_keys([' tt :name'])).to include('name')
      expect(I18nUpdator.fetch_view_keys([' #{tt(:name)}'])).to include('name')
      expect(I18nUpdator.fetch_view_keys([' #{tt (:name)}'])).to include('name')
      expect(I18nUpdator.fetch_view_keys([' '])).to be_empty
    end
  end

  describe '.to_human' do
    it 'translate keys to human friendly string' do
      expect(I18nUpdator.to_human(:may_ok)).to eq('May Ok')
      expect(I18nUpdator.to_human(:some_sleeping_factor)).to eq('Some Sleeping Factor')
    end
  end

  describe '.gtrans' do
    it 'get translation from google' do
      expect(I18nUpdator.gtrans('google', :zh)).to eq('谷歌')
    end
  end
end
