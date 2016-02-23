require_relative 'web_controller'

module LoggingHelper
  def output(msg)
    logger.request_info['session'] = 'some-session-id'
    logger.info msg
  end
end

# Use mongoid to store session data
class LoggerPage < WebController
  helpers LoggingHelper

  get '/' do
    logger.info 'here i am'
    output 'some message'
    logger.info 'here i am with sessiong'
    'hello'
  end

  Route << self
end
