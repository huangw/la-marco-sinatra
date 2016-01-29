require 'factory_girl'

require_all root_join('spec/support/factories/*_factory.rb')
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.after(:suite) do
    if ENV['RACK_ENV'] == 'production'
      puts "No fixture cleanup for production environment"
    else
      puts ' ------------ cleanup test database ------------ '
      ::Mongoid::Clients.default.database.drop
    end
  end
end
