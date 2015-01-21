# test user page
class UserPage < WebApplication
  get('/') { 'user root page' }
  Route << self
end
