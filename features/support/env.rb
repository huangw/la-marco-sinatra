# require 'uri'
require 'rspec/expectations'
require 'capybara/cucumber'

# setup environment
ENV['APP_ROOT'] = File.expand_path('../../..', __FILE__)
ENV['RACK_ENV'] ||= 'development'

# local settings, database sessions
require ENV['APP_ROOT'] + '/config/boot'

# require 'factory_girl'
# Dir[ENV['APP_ROOT'] +
#   '/spec/support/factories/*_factory.rb'].each { |f| require f }

case ENV['DRIVER']
when 'rack'
  Capybara.app = Rack::Builder.parse_file(ENV['APP_ROOT'] + '/config.ru').first
when 'chrome'
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.default_driver = :chrome
  Capybara.javascript_driver = :chrome
  Capybara.app_host = ENV['HOST'] || 'http://localhost:8080'
else
  require 'capybara/poltergeist'
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, debug: false)
  end

  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  Capybara.app_host = ENV['HOST'] || 'http://localhost:8080'
end

# mixin helper modules
class TestingWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
  # include FactoryGirl::Syntax::Methods

  def all_cookies
    case ENV['DRIVER']
    when 'rack'
      Capybara.current_session.driver.request.cookies
    when 'chrome'
      Capybara.current_session.driver.browser.manage.all_cookies
    else
      Capybara.current_session.driver.cookies
    end
  end

  def cookie(name)
    case ENV['DRIVER']
        when 'rack'
          Capybara.current_session.driver.request.cookies[name]
        when 'chrome'
          Capybara.current_session.driver.browser.manage.cookie_named(name)
        else
          c = Capybara.current_session.driver.cookies[name]
          return nil unless c
          [:name, :path, :expires, :domain, :value].reduce ({}) do |a, e|
            a[e] = c.send(e); a
          end
        end
  end

  I18n.locale = 'en'
end

World { TestingWorld.new }

# drop and seeds after test
at_exit do
  # puts 'Delete all image files'
  # Image.all.each(&:delete_files)
  #
  # puts 'Drop database'
  # Mongoid.default_session.drop
end
