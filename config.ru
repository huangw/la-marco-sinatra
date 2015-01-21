# vi: ft=ruby
require_relative 'config/boot'

# Application that maps all rack app registered in Route together
class Application < Sinatra::Base
  get('/') do
    name = 'Tom'
    'hello! ' + name
  end
  # Route.all.each { map }
end
run Application
