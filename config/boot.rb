# encoding: utf-8
# -----------------------------------------------------
#   GENERAL BOOT PROCESS WITH DYNAMIC LIBRARY LOADING
# -----------------------------------------------------
# Author: Huang Wei <huangw@pe-po.com>
# Version: 0.1.1; Created at: 2015/01/19;
# Version: 0.4.0; Created at: 2016/02/20;

# Use bundler for gems
require 'bundler/setup'
require 'dotenv'
Dotenv.load

ENV['APP_ROOT'] = File.expand_path('../..', __FILE__)
ENV['RACK_ENV'] ||= 'development'
ENV['BUNDLE_GEMFILE'] ||= File.join(ENV['APP_ROOT'], 'Gemfile')

# A shortcut to find local file's absolute path
def root_join(*path)
  File.join(ENV['APP_ROOT'], *path)
end

# Use `debug` instead `p` helps removes debug lines later
alias debug p

# Extend load path, add `app/lib` and `lib`
%w(lib app/lib).map { |d| $LOAD_PATH.unshift root_join(d) }

# Load active-support and home made core extensions
require 'active_support/all'
Dir[root_join('lib', 'core_ext', '*.rb')].each { |f| require f }

# Load settings
require 'confu'
Confu.for_environment(ENV['RACK_ENV']) do
  root ENV['APP_ROOT']
  environment ENV['RACK_ENV']
end
require_all root_join('config', 'settings', '*.rb')
Confu.descendants.map(&:'finalize!')
Confu.finalize!

# After boot: load initializers and environment specific initializers
require_all root_join('config', 'initializers', '*.rb')
require_all root_join('config', 'initializers', ENV['RACK_ENV'], '*.rb')
