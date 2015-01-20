# encoding: utf-8
require 'simplecov'
SimpleCov.start do
  add_group 'Specs', 'spec'
  add_filter 'spec/spec_helper.rb'
  coverage_dir 'doc/coverage'
end

# Development and debug
require 'pry'
require 'awesome_print'
AwesomePrint.defaults = { indent: 2, raw: true }


# Load the application contexts
ENV['RACK_ENV'] = 'test'
require_relative '../config/boot'

require 'rspec'
Dir[ENV['APP_ROOT'] + '/spec/support/**/*.rb'].each { |f| require f }
