require 'development/assets_mapper'

namespace :assets do
  desc 'update assets configuration file without downloading and compiling'
  task :map do
    AssetsMapper::Loader.new.execute!(:map)
  end

  desc 'update assets and assets configuration file'
  task :update do
    AssetsMapper::Loader.new.execute!(:update)
  end

  desc 'minimizing assets and assets configuration file'
  task :compile do
    AssetsMapper::Loader.new.execute!(:compile)
  end
end
