require 'sinatra/base'
require 'route'
require_relative 'web_exceptions'

deep_require root_join('lib/rack')
deep_require root_join('lib/controllers')
deep_require root_join('app/pages')
