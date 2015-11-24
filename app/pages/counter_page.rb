# Use mongoid to store session data
class CounterPage < Sinatra::Base
  configure do
    set :logging, nil
    set :root, Confu.root
  end

  use Rack::Session::Mongoid

  get '/' do
    session['counter'] ||= 0
    session['counter'] += 1
    "hello, world! (counter: #{session['counter']})"
  end

  Route.mount self, '/counter'
end
