# encoding: utf-8

# namespace for exceptions that known by the application
class ServerError < RuntimeError
  def status
    500
  end
end

# namespace for user input validation errors
class RequestError < ArgumentError
  def status
    400
  end
end

# validation errors occured in different layers
class ValidationError < RequestError; end

# Error for test application
class AuthenticationError < RequestError
  def status
    401
  end
end

# authorization error of the application level
class AuthorizationError < RequestError
  def status
    403
  end
end

# not found, etc.
class RouteError < RequestError
  def status
    404
  end
end
