# encoding: utf-8
# -----------------------------------------------------
#   GENERAL BOOT PROCESS WITH DYNAMIC LIBRARY LOADING
# -----------------------------------------------------
# Author: Huang Wei <huangw@pe-po.com>
# Version: 0.1.1; Created at: 2015/01/19;

RACK_ENV = ENV['RACK_ENV'] ||= 'development'
APP_ROOT = ENV['APP_ROOT'] = File.expand_path('../..', __FILE__)

def root_join(path)
  File.join(APP_ROOT, path)
end

# Load gem system and local core extensions
# -------------------------------------------
require 'rubygems'
require 'bundler/setup'

# Load libraries all core extensions
require 'active_support/all'
Dir[root_join('lib/core_ext/*.rb')].each { |f| require f }

# Extend load path with `app/lib` and `lib`
%w(lib app/lib).map do |d|
  $LOAD_PATH.unshift root_join(d) unless $LOAD_PATH.include?(root_join(d))
end

# RACK_ENV based configuration
# ------------------------------
Confu[RACK_ENV].root, Confu[RACK_ENV].env = APP_ROOT, RACK_ENV
Dir[root_join('config/environments/*_env.rb')].each { |f| require f }
Confu.finalize!

# Try to load database and application
# ----------------------------------------
try_require root_join('config/database')
try_require root_join('config/application')
