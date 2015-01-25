# Implements `cs|jss|img_tag` methods into controllers
module AssetsHelper
  # return :production, :local_assets, or :development
  def asset_env
    :development unless ENV['RACK_ENV'] == 'production'
    ENV['LOCAL_ASSETS'] ? :local_assets : :production
  end

  def img_tag
  end

  def css_tag
  end

  def js_tag
  end
end
