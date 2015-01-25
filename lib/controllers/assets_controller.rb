require 'sinatra/base'
# serve js/css files from local `app/assets` folder
class AssetsController < Sinatra::Base
  get '/settings' do
    AssetsSettings.get.to_hash.inspect
  end
end
