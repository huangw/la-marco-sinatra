# vi: ft=ruby
require_relative 'config/boot'
require 'la_buffered_logger'

# Application that maps all rack app registered in Route together
app = Rack::Builder.app do
  use Rack::LogFlusher, logger: LaBufferedLogger
  Route.all.each { |path, klass| map(path) { run klass } }
end
run app
