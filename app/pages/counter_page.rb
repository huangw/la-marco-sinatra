require_relative 'web_controller'

# Use mongoid to store session data
class CounterPage < WebController
  get '/' do
    session['counter'] ||= 0
    session['counter'] += 1
    "hello, world! (counter: #{session['counter']})"
  end

  Route.mount self, '/counter'
end
