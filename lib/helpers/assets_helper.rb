# Implements `cs|jss|img_tag` methods into controllers
module AssetsHelper
  def img_tag(file_id, opts = {})
    opts['src'] = File.join(settings.assets.img_url_prefix, file_id)
    attrs = opts.map { |k, v| format('%s="%s"', k, v) }.join(' ')
    format '<image %s\>', attrs
  end

  def css_tag
  end

  def js_tag
  end
end
