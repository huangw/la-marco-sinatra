require 'spec_helper'
require 'assets_settings'

describe AssetsSettings do
  describe '#[]' do
    it 'get an instance of EnvironmentSettings with default' do
      expect(AssetsSettings[:production]).to be_instance_of(AssetsSettings::EnvironmentSettings)
      expect(AssetsSettings[:production].img_dir).to eq('app/assets/img')
      expect(AssetsSettings[:production]['application.js'].urls).to be_empty
    end
  end

  describe '#to_hash/#from_hash' do
    it 'convert settings to/from hash' do
      AssetsSettings[:production]['application.js'] << 'minimizingme.js'
      AssetsSettings[:development]['application.js'] << ['build_part1.js', 'build_part2.js']
      hsh = AssetsSettings.to_hash

      expect(hsh[:production][:files]['application.js'].last).to eq('minimizingme.js')
      expect(hsh[:development][:files]['application.js']).to eq(['build_part1.js', 'build_part2.js'])

      hsh2 = AssetsSettings.from_hash(hsh).to_hash
      expect(hsh2[:production][:files]['application.js']).to eq(hsh[:production][:files]['application.js'])
      expect(hsh2[:development][:files]['application.js']).to eq(['build_part1.js', 'build_part2.js'])
    end
  end
end
