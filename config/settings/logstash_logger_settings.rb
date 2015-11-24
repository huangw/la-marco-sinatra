# Configuration for Logstash Logger
require 'logstash-logger'
def global_logger
  if ENV['RACK_ENV'].to_s == 'production'
    LogStashLogger.new(type: :udp, host: 'localhost', port: 5228)
  else
    LogStashLogger.new(type: :stdout)
  end
end
