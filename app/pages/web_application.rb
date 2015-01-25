require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'sinatra/content_for'

require 'helpers/slim_helper'
require 'helpers/form_helper'
require 'helpers/i18n_helper'

# TODO: load assets controllers
# require 'development/assets_mapper/asset_controller'
# ENV['LOCAL_ASSETS'] = 'TRUE' unless ENV['RACK_ENV'] == 'production'
# Route.mount(AssetsMapper::ImageController, '/img') if ENV['LOCAL_ASSETS']

# Web application without database related settings
class WebApplication < Sinatra::Base
  configure do
    set :root, Confu.root
    set :views, root_join('/app/views')
    # TODO: load assets
    set :protection, except: :remote_token
  end

  helpers Sinatra::ContentFor
  register Sinatra::Flash
  helpers Sinatra::RedirectWithFlash

  # TODO: helpers AssetsHelper
  helpers FormHelper
  helpers SlimHelper

  helpers I18nHelper
  before { I18n.locale = preferred_locale }
end
