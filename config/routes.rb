require 'sinatra/base'
require 'route'

# Load environment specific settings if file exists
try_require root_join("config/environments/#{RACK_ENV}")
deep_require root_join('app/pages')
