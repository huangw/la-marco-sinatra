# vi: ft=ruby
require_relative 'config/boot'

# Application that maps all rack app registered in Route together
app =Rack::Builder.app do
  Route.all.each { |path, klass| map(path) { run klass } }
end

run app
