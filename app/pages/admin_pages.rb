require_relative 'web_application'

# Routing for controllers nested in name space
module Admin
  # root for administrator pages
  class RootPage < WebApplication
    get('/') do
      'This is the root of administration portal'
    end

    get('/settings') do
      rsp
    end

    Route.mount(self, '/admin')
  end
end
