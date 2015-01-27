# An asset mapper class
module AssetMapper
  # Source file to produce
  class Sfile
    attr_reader :filename

    def initialize(filename)
      warn "[WARN] file type unkown: #{filename}, "\
           'need to be js or css' unless filename.match(/\.(js|css)\Z/)
      @filename = filename
    end

    def need_compile?
      true
    end

    # File type
    # ------------
    def file_type
      filename.match(/\.js\Z/) ? 'js' : 'css'
    end

    def js?
      file_type == 'js'
    end

    def css?
      file_type == 'css'
    end

    # Paths and Urls
    # -----------------
    # File path always relative path to root and used in urls
    def file_path
      File.join(AssetMapper.assets_dir, filename)
    end

    def abs_path
      File.join(AssetMapper.root, file_path)
    end

    # Only available for :development
    def local_url
      File.join(AssetSettings[:local_assets].assets_url_prefix, file_path)
    end

    def production_url
      nil
    end
  end
end
