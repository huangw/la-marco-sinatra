# encoding: utf-8
# Backward compatible settings
require 'mongoid'

Mongoid.logger.level = Logger::WARN
Mongo::Logger.logger.level = Logger::WARN

# Load configuration from yaml file
Mongoid.load!(root_join('config/mongoid.yml'), ENV['RACK_ENV'])

# Load mixin function and custom modules into Mongoid
deep_require root_join('lib/mongoid')
deep_require root_join('app/lib/mongoid')
deep_require root_join('app/models')

# Ensure index each restart
::Mongoid.models.map(&:create_indexes)
