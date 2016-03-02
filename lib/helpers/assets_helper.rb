# Implements `cs|jss|img_tag` methods into controllers
module AssetsHelper
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

  def img_url(obj, opts = {})
    return obj.url unless obj.is_a?(String)
    obj =~ /^\// ? obj : File.join(AssetSettings.get.img_url_prefix, obj)
  rescue
    default_img_url(opts[:suffix], opts[:type])
  end

  def default_img_url(suffix = 'o', type = 'Image')
    File.join(AssetSettings.get.img_url_prefix,
              'defaults',
              "#{type.to_s.underscore}-#{suffix}.png")
  end

  def img_tag(obj, opts = {})
    opts[:suffix] ||= 'o'
    opts[:type] ||= 'Image'

    opts['src'] = img_url(obj, opts)

    # Set the default alt
    opts['alt'] ||= obj.split(/\//).last if obj.is_a?(String)
    opts['alt'] ||= obj.alt if obj.methods.include?(:alt)
    opts['alt'] ||= ftt(:img_not_found)

    attrs = opts.map { |k, v| format('%s="%s"', k, v) }.join(' ')
    format '<image %s />', attrs
  end
end
