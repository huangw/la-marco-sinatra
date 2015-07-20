# Configuration for Logstash Logger
require 'logstash-logger'
def global_logger
  if ENV['RACK_ENV'].to_s == 'production'
    LogStashLogger.new(type: :udp, host: 'localhost', port: 5228)
  else
    lg = LogStashLogger.new(type: :stdout)
    lg.level = ::Logger::WARN
    lg
  end
end
