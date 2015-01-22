# encoding: utf-8
# -----------------------------------------------------
#   GENERAL BOOT PROCESS WITH DYNAMIC LIBRARY LOADING
# -----------------------------------------------------
# Author: Huang Wei <huangw@pe-po.com>
# Version: 0.1.1; Created at: 2015/01/19;

# Use bundler for gems
require 'bundler/setup'

ENV['RACK_ENV'] ||= 'development'
ENV['APP_ROOT'] = File.expand_path('../..', __FILE__)

# A shortcut to find local file's absolute path
def root_join(path)
  File.join(ENV['APP_ROOT'], path)
end

# Load active-support and home made core extensions
require 'active_support/all'
Dir[root_join('lib/core_ext/*.rb')].each { |f| require f }

# Extend load path, add `app/lib` and `lib`
%w(lib app/lib).map { |d| $LOAD_PATH.unshift root_join(d) }

# Load settings
require 'confu'
Confu.for_environment(ENV['RACK_ENV']) do
  root ENV['APP_ROOT']
  environment ENV['RACK_ENV']
end
Dir[root_join('config/settings/*.rb')].each { |f| require f }
Confu.descendants.map(&:'finalize!')
Confu.finalize!

# Try to load database
try_require root_join('config/database')

# Try to load web application
try_require root_join('config/routes')

# After boot: load environment specific initializers
Dir[root_join("config/initializers/#{ENV['RACK_ENV']}/*.rb")].each do |f|
  require f
end
