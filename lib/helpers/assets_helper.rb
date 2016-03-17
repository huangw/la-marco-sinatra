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

  def img_tag(obj, opts = {})
    begin
      opts[:suffix] ||= 'o'

      # opts type defaults String is 404
      raise RequestError, :not_a_image unless check_img_obj(obj)

      opts[:type] ||= obj._mt if obj.is_a?(ImageLabel)
      opts[:type] ||= obj.class

      # opts url
      opts[:src] ||= img_obj_url(obj, opts)

      # opts alt
      opts[:alt] ||= obj.split(/\//).last if obj.is_a?(String)
      opts[:alt] ||= obj.alt
    rescue
      opts[:type] ||= 'Image'
      opts[:src] ||= default_img_url(opts[:suffix], opts[:type])
      opts[:alt] ||= ftt(:img_not_found)
    end

    attrs = opts.map { |k, v| format('%s="%s"', k, v) }.join(' ')
    format '<image %s />', attrs
  end

  def img_obj_url(obj, opts)
    if obj.is_a? String
      obj =~ /^\// ? obj : File.join(AssetSettings.get.img_url_prefix, obj)
    else
      obj.resized_url(opts[:suffix])
    end
  end

  def default_img_url(suffix, type)
    File.join(AssetSettings.get.img_url_prefix,
              'defaults',
              "#{type.to_s.underscore}-#{suffix}.png")
  end

  # only accept ImageLabel, Image or String
  def check_img_obj(obj)
    return true if obj.is_a?(ImageLabel)
    return true if obj.is_a?(Image)
    obj.is_a?(String) && (obj =~ /\./)
  end
end
