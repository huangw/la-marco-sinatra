require_relative 'web_application'

# Routing for controllers nested in name space
module Admin
  # root for administrator pages
  class RootPage < WebApplication
    get('/') { 'This is the root of administration portal' }

    Route.mount(self, '/admin')
  end
end
