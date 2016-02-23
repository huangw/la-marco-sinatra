require 'rack/session/abstract/id'
module Rack
  module Session
    class Mongoid < Abstract::ID
      VERSION = '0.1.0'.freeze
    end
  end
end
