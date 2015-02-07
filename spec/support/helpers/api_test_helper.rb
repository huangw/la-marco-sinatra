require 'rack/test'
require 'multi_json'
require 'recursive-open-struct'

# API test helper for converting restful json response to object-like structure
module APITestHelper
  include Rack::Test::Methods

  def app
    Rack::Builder.app do
      Route.all.each { |path, klass| map(path) { run klass } }
    end
  end

  # add `response(some end point).hash_key.hash_key` matcher
  def r(req = nil, body = nil, headers = {})
    if req
      met, url = req.split(/\s+/, 2)
      send(met.downcase.to_sym, url, body, headers)
    end
    j2o
  end

  def s
    last_response.status
  end

  def sp(expected_status = 200)
    ap MultiJson.load(last_response.body) unless last_response.status.to_i == expected_status
    last_response.status
  end

  def j2o(json = nil)
    json ||= last_response.body
    RecursiveOpenStruct.new(MultiJson.load(json))
  end
end

RSpec.configure do |config|
  config.include APITestHelper
end
