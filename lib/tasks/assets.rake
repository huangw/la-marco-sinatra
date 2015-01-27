require 'development/asset_mapper'

namespace :assets do
  desc 'update assets and assets configuration file'
  task :update do
    AssetMapper::Loader.new.execute!(false)
  end

  desc 'update and minimizing assets and assets configuration file'
  task :compile do
    AssetMapper::Loader.new.execute!(true)
  end
end
