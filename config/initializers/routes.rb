require 'sinatra/base'
require 'route'

# namespace for exceptions that known by the application
class ServerError < RuntimeError
  def status
    500
  end
end

class RequestError < ArgumentError
  def status
    400
  end
end

# validation errors occured in different layers
class ValidationError < RequestError; end

# not found, etc.
class RouteError < RequestError
  def status
    404
  end
end

deep_require root_join('lib/rack')
deep_require root_join('app/pages')
