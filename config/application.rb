require 'sinatra/base'
# require 'route'
try_require root_join("config/environment/#{RACK_ENV}")

# Application that maps all rack app registered in Route together
class Application < Sinatra::Base
  get('/') { 'hello!' }
end
