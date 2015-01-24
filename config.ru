# vi: ft=ruby
require_relative 'config/boot'
# require 'development/assets_mapper/asset_controller'
require 'development/assets_mapper/image_controller'

ENV['LOCAL_ASSETS'] = 'TRUE' unless ENV['RACK_ENV'] == 'production'
Route.mount(AssetsMapper::ImageController, '/img') if ENV['LOCAL_ASSETS']

# Application that maps all rack app registered in Route together
app =Rack::Builder.app do
  Route.all.each { |path, klass| map(path) { run klass } }
end

run app
