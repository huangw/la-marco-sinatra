require 'sinatra/content_for'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

require 'helpers/form_helper'
require 'helpers/slim_helper'
require 'helpers/i18n_helper'

require 'asset_settings'
require 'helpers/assets_helper'

# Web application without database related settings
class WebApplication < Sinatra::Base
  configure do
    set :root, Confu.root
    set :views, root_join('/app/views')
    set :assets, AssetSettings.get
    set :protection, except: :remote_token
  end

  helpers Sinatra::ContentFor
  register Sinatra::Flash
  helpers Sinatra::RedirectWithFlash

  helpers FormHelper
  helpers SlimHelper
  helpers I18nHelper
  helpers AssetsHelper

  before { I18n.locale = preferred_locale }
end
