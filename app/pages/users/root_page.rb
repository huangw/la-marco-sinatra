# Test user page routing
class UserPage < WebApplication
  get('/') do
    # 'user root page'
    self.class.to_s
  end

  Route.mount(self, '/')
end
