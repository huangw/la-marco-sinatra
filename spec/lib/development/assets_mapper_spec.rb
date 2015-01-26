require 'spec_helper'
require 'development/assets_mapper'

describe AssetsMapper do
  subject(:am) { AssetsMapper::Loader.new }
  it 'can set global vars' do
    am.img_dir 'some/other/directory'
    expect(AssetsSettings[:production].img_dir).to eq('some/other/directory')

    am.img_dir local_assets: 'yet/an/other/place'

    expect(AssetsSettings[:production].img_dir).to eq('some/other/directory')
    expect(AssetsSettings[:development].img_dir).to eq('some/other/directory')
    expect(AssetsSettings[:local_assets].img_dir).to eq('yet/an/other/place')
  end
end
