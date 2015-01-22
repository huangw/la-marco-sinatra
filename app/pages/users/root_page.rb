# Test user page routing
class UserPage < WebApplication
  get('/') { 'user root page' }
  Route.mount(self, '/')
end
