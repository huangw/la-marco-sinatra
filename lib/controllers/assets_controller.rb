require 'sinatra/base'
require 'json'

# serve js/css files from local `app/assets` folder
class AssetsController < Sinatra::Base
  configure { enable :inline_templates }
  before { @assets_dir = AssetsSettings.get.assets_dir }

  get '/settings' do
    format '<html><body><pre>%s</pre></body></html>',
           JSON.pretty_generate(AssetsSettings.get.to_hash)
  end

  get(%r{\/([\w\/\-\.]+)}) { |f| send_file(File.join(ENV['APP_ROOT'], f)) }
end
