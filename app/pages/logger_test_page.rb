require_relative 'web_application'

# Test for asset helper settings
class LoggerTestPage < WebApplication
  get '/' do
    logger.error 'Oh! An error occurred'
    'add a logger as error'
  end

  get '/raise' do
    fail 'An runtime error occurred'
  end

  Route << self
end
