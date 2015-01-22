# Routing for controllers nested in name space
module Admin
  # user management in administrate pages
  class UserPage < WebApplication
    get('/') { 'This is where the administrator manages users' }

    get('/someid') { 'This page for user with some id' }

    Route << self
  end
end
