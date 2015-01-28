# Routing for controllers nested in name space
module Admin
  # user management in administrate pages
  class UserPage < WebApplication
    get('/') { 'This is where the administrator manages users' }

    get('/someid') do
      'This page for user with some id'
    end

    get('/match/me/*/to') do
    end

    Route << self
  end
end
