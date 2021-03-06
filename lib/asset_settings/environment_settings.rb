# Belongs to asset settings
class AssetSettings
  # Settings for each specific environment, singleton get one at runtime
  class EnvironmentSettings
    attr_accessor :img_dir, :img_url_prefix, :assets_url_prefix, :files

    def initialize(environment)
      @environment = environment.to_sym

      # initialize with default values
      @img_dir = 'app/assets/img'
      @files = {}
      @img_url_prefix = production? ? 'http://vikkr.com/img' : '/img'
      @assets_url_prefix = production? ? 'http://vikkr.com' : '/assets'
    end

    def production?
      @environment == :production
    end

    # Convenient accessors
    # ----------------------
    def [](filename)
      raise "Invalid filename #{filename}, "\
           'must end with js or css' unless filename =~ /\.(js|css)\Z/
      @files[filename] ||= [] # URL list
    end

    # Load from and dump to a hash presentation
    # ------------------------------
    def hash_keys
      [:img_dir, :img_url_prefix]
    end

    def to_hash
      hsh = hash_keys.reduce({}) { |a, e| a[e] = send(e); a }
      hsh[:files] = {}
      @files.each { |f, lst| hsh[:files][f] = lst.uniq }
      hsh
    end

    def from_hash(hsh)
      hash_keys.each { |k| send("#{k}=", hsh[k]) }
      hsh[:files].each { |f, lst| @files[f] = lst.uniq }
      self
    end
  end
end
