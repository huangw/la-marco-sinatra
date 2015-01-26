# Implements `cs|jss|img_tag` methods into controllers
module AssetsHelper
  def img_tag(file_id, opts = {})
    opts['src'] = File.join(settings.assets.img_url_prefix, file_id)
    attrs = opts.map { |k, v| format('%s="%s"', k, v) }.join(' ')
    format '<image %s\>', attrs
  end

  def css_tag(file_id)
    settings.assets[file_id].urls.map do |url|
      url = File.join(settings.assets.assets_url_prefix, url)
      format('<link rel="stylesheet" type="text/css" href="%s" />', url)
    end
  end

  def js_tag
    settings.assets[file_id].urls.map do |url|
      url = File.join(settings.assets.assets_url_prefix, url)
      format('<script type="text/javascript" src="%s"></script>', url)
    end
  end
end
