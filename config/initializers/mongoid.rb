# encoding: utf-8
# Backward compatible settings
require 'mongoid'

Mongoid.logger.level = Logger::WARN
Mongo::Logger.logger.level = Logger::WARN

# Load configuration from yaml file
Mongoid.load!(root_join('config/mongoid.yml'), ENV['RACK_ENV'])

# Load mixin function and custom modules into Mongoid
require 'utils/hash_struct'
require 'utils/hash_presenter'
deep_require root_join('lib/struct')
deep_require root_join('lib/mongoid')
deep_require root_join('lib/models')

deep_require root_join('app/lib')
deep_require root_join('app/models')

# Ensure index each restart
::Mongoid.models.map(&:create_indexes)
