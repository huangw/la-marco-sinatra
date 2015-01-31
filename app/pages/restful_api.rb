# encoding: utf-8
# require_relative 'la_sinatra_web'

# Error for test application
class AuthenticationError < ServerError
  def status
    401
  end
end

# test the restful response settings
class RestfulAPI < Sinatra::Base
  configure do
    set :show_exceptions, false # true if development?
    set :raise_errors, true # let exceptions pass through (to responser)
  end

  use Rack::LogFlusher, logger: LaBufferedLogger
  use Rack::JsonResponse

  helpers do
    def common_rsp
      env['response_hash'] ||= {}
    end
  end

  before do
    I18n.locale = params[:locale] if params[:locale]
  end
  # Routes
  # ------------
  get '/' do
    val = params['val'] || 'world'
    { hello: val }
  end

  get '/error' do
    fail 'can not avoid'
  end

  get '/auth_error' do
    fail AuthenticationError, 'returns 401'
  end

  get '/common' do
    common_rsp[:name] = 'good person'

    { age: 18 }
  end

  get '/i18n' do
    { button: I18n.t('image_storage_error.unsupported_image_type') }
  end

  Route[self] = '/api'
end
