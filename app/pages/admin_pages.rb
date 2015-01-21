require_relative 'web_application'

module Admin
  class RootPage < WebApplication
    get('/') { 'This is the root of administration portal' }

    Route.mount(self, '/admin')
  end
end
