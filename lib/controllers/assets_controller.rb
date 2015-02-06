require 'sinatra/base'
require 'asset_settings'

# serve js/css files from local `app/assets` folder
class AssetsController < Sinatra::Base
  get(%r{\/([\w\/\-\.]+)}) { |f| send_file(File.join(ENV['APP_ROOT'], f)) }

  # load assets controllers
  unless AssetSettings.production?
    Route.mount(self, AssetSettings.get.assets_url_prefix)
  end
end
