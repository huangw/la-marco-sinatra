require 'development/assets_mapper'

namespace :assets do
  desc 'process assets update and assets configuration file'
  task :update do
    AssetsMapper.update!
  end

  desc 'update assets configuration file without downloading'
  task :map do
  end
end
