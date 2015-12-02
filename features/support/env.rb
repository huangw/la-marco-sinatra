# require 'uri'
require 'rspec/expectations'
require 'capybara/cucumber'

# boot the application environment
ENV['RACK_ENV'] ||= 'development' # for easy checking database
ENV['HOST'] ||= 'http://localhost:8080'
require_relative '../../config/boot'

if ENV['DRIVER'] == 'chrome'
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.default_driver = :chrome
  Capybara.javascript_driver = :chrome
  Capybara.app_host = ENV['HOST']
else # default driver
  require 'capybara/poltergeist'
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, debug: false)
  end

  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  Capybara.app_host = ENV['HOST']
end

# mixin helper modules
class FeatureWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
  # include FactoryGirl::Syntax::Methods

  def all_cookies
    if ENV['DRIVER'] == 'chrome'
      Capybara.current_session.driver.browser.manage.all_cookies
    else
      Capybara.current_session.driver.cookies
    end
  end

  def cookie(name)
    if ENV['DRIVER'] == 'chrome'
      Capybara.current_session.driver.browser.manage.cookie_named(name)
    else
      c = Capybara.current_session.driver.cookies[name]
      return nil unless c
      [:name, :path, :expires, :domain, :value].reduce ({}) do |a, e|
        a[e] = c.send(e); a
      end
    end
  end
end

World { FeatureWorld.new }

# cleanup after cucumber
at_exit do
  # puts 'Delete all image files'
  # Image.all.each(&:delete_files)
  #
  # puts 'Drop database'
  # Mongoid.default_session.drop
  #
  # puts 'seeds'
  # `rake db:seeds`
end
