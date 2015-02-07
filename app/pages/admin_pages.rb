require_relative 'web_application'
require 'la_buffered_logger'

# Routing for controllers nested in name space
module Admin
  # root for administrator pages
  class RootPage < WebApplication
    get('/') do
      logger.error 'Catch an error'
      'This is the root of administration portal'
    end

    get('/settings') do
      rsp
    end

    Route.mount(self, '/admin')
  end
end
