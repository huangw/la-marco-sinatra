# Configuration for Logstash Logger
require 'logstash-logger'

# Singleton factory of global loggers
class GlobalLogger
  class << self
    def instance
      @logger ||= if ENV['RACK_ENV'].to_s == 'production'
                    LogStashLogger.new(type: :tcp, host:
                                       'localhost', port: 5229)
                  else
                    LogStashLogger.new(type: :stdout)
                  end
    end
  end
end
