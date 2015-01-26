require 'sinatra/base'

# serve js/css files from local `app/assets` folder
class AssetsController < Sinatra::Base
  get(%r{\/([\w\/\-\.]+)}) { |f| send_file(File.join(ENV['APP_ROOT'], f)) }
end
