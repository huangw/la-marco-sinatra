require 'sinatra/base'
# require 'route'
try_require root_join("config/environments/#{RACK_ENV}")

# Application that maps all rack app registered in Route together
class Application < Sinatra::Base
  get('/') do
    name = 'Tom'
    binding.pry
    'hello! ' + name
  end
end
