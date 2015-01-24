require 'sinatra/base'

# Serve image, css and js files from /app/assets
module AssetsMapper
  class AssetController < Sinatra::Base
    # Serve the single file with the file name
    get('/:file') do
      send_file(root_join(assets[:img_dir], params[:file]))
    end

    # List the configuration of assets list
    get('/index') do
    end
  end
  # Route.mount(self, '/img')
end
