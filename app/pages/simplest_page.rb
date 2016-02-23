# simplest hello world application
class SimplestPage < Sinatra::Base
  configure do
    set :logging, nil
    set :root, Confu.root
  end

  get '/' do
    'Hello, world!'
  end

  Route.mount self, '/simple'
end
