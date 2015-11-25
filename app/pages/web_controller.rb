require 'sinatra/content_for'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

# load asset setting from `config/assets.yml` file
require 'asset_settings'

# Web application with mongoid session store
class WebController < Sinatra::Base
  configure do
    set :logging, nil
    set :root, Confu.root
    set :views, root_join('/app/views')
    set :assets, AssetSettings.get
    set :protection, except: :remote_token
  end

  use Rack::Session::Mongoid

  helpers Sinatra::ContentFor
  register Sinatra::Flash
  helpers Sinatra::RedirectWithFlash

  helpers FormHelper
  helpers SlimHelper
  helpers I18nHelper
  helpers AssetsHelper

  before { I18n.locale = preferred_locale }
end
