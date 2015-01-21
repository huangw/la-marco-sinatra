class Admin::UserPage < WebApplication
  get('/') { 'This is where the administrator manages users' }

  get('/someid') { 'This page for user with some id' }

  Route << self
end
