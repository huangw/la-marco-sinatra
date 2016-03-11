require_relative 'web_controller'

# Use mongoid to store session data
class NodocPage < WebController
  get '/' do
    Email.s_find('noexist')
  end

  Route.mount self, '/nodocs'
end
