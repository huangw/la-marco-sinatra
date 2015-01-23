require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'sinatra/content_for'

require 'helpers/slim_helper'
require 'helpers/i18n_helper'

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
  # helpers FlashesHelper # TODO: need?

  # TODO: common rsp
  # helpers AssetsHelper
  # helpers FormHelper
  helpers SlimHelper

  helpers I18nHelper
  before {
    @common_name = 'The Name'
    I18n.locale = preferred_locale
  }
end
