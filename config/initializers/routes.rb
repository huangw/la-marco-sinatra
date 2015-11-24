require 'sinatra/base'
require 'route'
require_relative 'web_exceptions'

try_require root_join('config/initializers/mongoid')

deep_require root_join('lib/rack')
deep_require root_join('lib/helpers')
deep_require root_join('lib/controllers')

deep_require root_join('app/rack')
deep_require root_join('app/helpers')
deep_require root_join('app/pages')
