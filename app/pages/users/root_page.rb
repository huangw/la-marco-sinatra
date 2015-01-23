# Test user page routing
class UserPage < WebApplication
  get('/') do
    # self.class.to_s
    'user root page'
  end

  Route.mount(self, '/')
end
