require 'asset_settings/environment_settings'
# Bind to `config/assets.yml`, singleton parse it's contents or
# update based on configurations
class AssetSettings
  CONFIG_YAML = 'config/assets.yml'.freeze
  APP_ROOT = ENV['APP_ROOT']

  class << self
    attr_reader :settings
    # load yaml unless loaded then return the settings corresponding current
    # runtime environment (one of the three from environments)
    def get
      load_yaml unless @loaded
      @loaded = true
      self[assets_env]
    end

    # access for specific environment settings
    def [](env)
      raise "Unsupported environment #{env}" unless environments.include?(env)
      @settings ||= {}
      @settings[env.to_sym] ||= EnvironmentSettings.new(env.to_sym)
    end

    # list up all supported environment
    def environments
      [:production, :local_assets, :development]
    end

    # runtime status
    # -----------------
    # return assets environment for current runtime, one of:
    # :production, :local_assets, or :development
    def assets_env
      return :development unless ENV['RACK_ENV'] == 'production'
      ENV['LOCAL_ASSETS'] ? :local_assets : :production
    end

    def production?
      assets_env == :production
    end

    def local_assets?
      assets_env == :local_assets
    end

    def development?
      assets_env == :development
    end

    # File binding
    # -------------
    def from_hash(hsh)
      environments.each { |k| self[k].from_hash(hsh[k]) if hsh[k] }
      self
    end

    def to_hash
      environments.reduce({}) { |a, e| a[e] = self[e].to_hash; a }
    end

    def load_yaml(file = nil)
      file ||= File.join(APP_ROOT, CONFIG_YAML)
      return false unless File.exist?(file)
      from_hash YAML.load_file(file)
      self
    end

    def load_yaml!(file = nil)
      raise 'file not exists' unless load_yaml(file)
    end

    def update_yaml!(file = nil)
      file ||= File.join(APP_ROOT, CONFIG_YAML)
      File.open(file, 'w') { |fh| fh.write YAML.dump(to_hash) }
    end
  end
end
