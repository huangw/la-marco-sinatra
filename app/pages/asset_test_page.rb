require_relative 'web_application'

# Test for asset helper settings
class AssetTestPage < WebApplication
  get '/settings/:key' do
    settings.assets.send(params[:key])
  end

  get '/image/icon/orange.jpg' do
    format '<html><body>%s</body></html>', img_tag('icon/orange.jpg')
  end

  get '/bootstrap' do
    css_tag('application.css')
  end

  Route << self
end
