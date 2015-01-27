require 'development/asset_mapper'

namespace :assets do
  desc 'update assets configuration file without downloading and compiling'
  task :map do
    AssetMapper::Loader.new.execute!(:map)
  end

  desc 'update assets and assets configuration file'
  task :update do
    AssetMapper::Loader.new.execute!(:update)
  end

  desc 'minimizing assets and assets configuration file'
  task :compile do
    AssetMapper::Loader.new.execute!(:compile)
  end
end
