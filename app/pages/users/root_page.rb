# Test user page routing
class UserPage < WebApplication
  get('/') do
    'user root page'
  end

  Route.mount(self, '/')
end
