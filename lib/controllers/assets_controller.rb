require 'sinatra/base'
require 'json'

# serve js/css files from local `app/assets` folder
class AssetsController < Sinatra::Base
  configure { enable :inline_templates }

  get '/settings' do
    format '<html><body><pre>%s</pre></body></html>',
           JSON.pretty_generate(AssetsSettings.get.to_hash)
  end
end
