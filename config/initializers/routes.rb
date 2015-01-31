require 'sinatra/base'
require 'route'

# Namespace for exceptions that known by the application
class ServerError < RuntimeError
  def status
    500
  end
end

# Generic
class RequestError < ArgumentError
  def status
    400
  end
end

# Validation errors occured in different layers
class ValidationError < RequestError; end

# Not found, etc.
class RouteError < RequestError
  def status
    404
  end
end

deep_require root_join('lib/rack')
deep_require root_join('app/pages')
