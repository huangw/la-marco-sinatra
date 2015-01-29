# Implements `cs|jss|img_tag` methods into controllers
module AssetsHelper
  def img_tag(file_id, opts = {})
    opts['src'] = File.join(settings.assets.img_url_prefix, file_id)
    attrs = opts.map { |k, v| format('%s="%s"', k, v) }.join(' ')
    format '<image %s\>', attrs
  end

  def css_tag(file_id)
    settings.assets[file_id].map do |url|
      format('<link rel="stylesheet" type="text/css" href="%s" />', url)
    end.join('')
  end

  def js_tag(file_id)
    settings.assets[file_id].map do |url|
      format('<script type="text/javascript" src="%s"></script>', url)
    end.join('')
  end
end
