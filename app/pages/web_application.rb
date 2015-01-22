require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

require 'sinatra/content_for'
require 'helpers/slim_helper'

# Web application without database related settings
class WebApplication < Sinatra::Base
  configure do
    set :root, Confu.root
    set :views, root_join('/app/views')
    # TODO: load assets
    set :protection, except: :remote_token
  end

  helpers Sinatra::ContentFor
  helpers SlimHelper

  register Sinatra::Flash
  helpers Sinatra::RedirectWithFlash
  # helpers FlashesHelper

  # TODO: common rsp
  # helpers AssetsHelper
  # helpers FormHelper

  # helpers I18nHelper
  # before do
  #   init_locale
  # end
end
