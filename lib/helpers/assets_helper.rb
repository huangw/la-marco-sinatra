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

  def default_img_url(suffix = 'o', type = 'Image')
    File.join(AssetSettings.get.img_url_prefix,
              'defaults',
              "#{type.to_s.underscore}-#{suffix}.png")
  end

  def default_img_alt(obj)
    if obj.is_a? Image
      obj.oname
    elsif obj.is_a? String
      obj.split(/\//).last
    else
      ftt(:img_not_found)
    end
  end

  def img_url(obj, opts = {})
    opts[:suffix] ||= 'o'
    opts[:type] ||= 'Image'

    if obj.is_a? Image
      obj.url(opts[:suffix])
    elsif obj.is_a? String
      File.join(AssetSettings.get.img_url_prefix, obj)
    else
      default_img_url(opts[:suffix], opts[:type])
    end
  end

  def img_tag(obj, opts = {})
    opts['src'] = img_url(obj, opts)
    opts['alt'] = default_img_alt(obj)
    attrs = opts.map { |k, v| format('%s="%s"', k, v) }.join(' ')
    format '<image %s/>', attrs
  end
end
