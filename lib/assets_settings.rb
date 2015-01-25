require 'yaml'
# Bind assets related settings from `config/assets.yml`
class AssetsSettings
  CONFIG_YAML = 'config/assets.yml'
  APP_ROOT = ENV['APP_ROOT']

  # A js/css file id should be served as a list of urls by AssetsHelper
  class AssetsFile
    attr_accessor :name, :urls
    def initialize(name)
      @name, @urls = name, []
    end

    def <<(source_file)
      source_file = [source_file] unless source_file.is_a?(Array)
      source_file.each { |f| urls << f }
    end
  end

  # same format for each environment, can serialize to/from hash
  class EnvironmentSettings
    attr_accessor :env, :files # file_name => AssetFile

    def initialize(env)
      @env, @files = env, {}
      AssetsSettings.default_values.each do |met, default|
        instance_variable_set("@#{met}", default)  # set default value

        define_singleton_method met do |val = nil| # a getter/setter
          instance_variable_set("@#{met}", val) unless val.nil?
          instance_variable_get("@#{met}")
        end
      end
    end

    # Add or fetch the list of urls for the asset file with id `filename`,
    # such as `application.js`
    def [](filename)
      fail "Invalid filename #{filename}, "\
           'must end with js or css' unless filename.match(/\.(js|css)\Z/)
      @files[filename] ||= AssetsFile.new(filename)
    end

    def to_hash
      hsh = {}
      global_keys.each { |k| hsh[k] = instance_variable_get("@#{k}") }
      hsh[:files] = {}
      @files.each { |fname, file| hsh[:files][fname] = file.urls }
      hsh
    end

    def from_hash(hsh)
      global_keys.each { |k| send(k, hsh[k]) if hsh.key?(k) }
      hsh[:files].each { |f_id, urls| self[f_id].urls = urls } if hsh[:files]
      self
    end

    def global_keys
      AssetsSettings.default_values.keys
    end
  end

  # The settings are accessed in one global singleton class
  class << self
    attr_accessor :env_settings

    # return assets environment for current runtime, one of:
    # :production, :local_assets, or :development
    def assets_env
      return :development unless ENV['RACK_ENV'] == 'production'
      ENV['LOCAL_ASSETS'] ? :local_assets : :production
    end

    # list up all supported environment
    def environments
      [:production, :local_assets, :development]
    end

    def [](env)
      fail "Unsupported environment #{env}" unless environments.include?(env)
      @settings ||= {}
      @settings[env.to_sym] ||= EnvironmentSettings.new(env.to_sym)
    end

    def load_yaml(file = nil)
      file ||= File.join(APP_ROOT, CONFIG_YAML)
      return false unless File.exists?(file)
      from_hash YAML.load_file(file)
    end

    def load_yaml!(file = nil)
      fail 'file not exists' unless load_file(file)
    end

    def from_hash(hsh)
      environments.each { |k| self[k].from_hash(hsh[k]) if hsh[k] }
      self
    end

    def to_hash
      hsh = {}
      environments.each { |k| hsh[k] = self[k].to_hash }
      hsh
    end

    def update_yaml!(file = nil)
      file ||= File.join(APP_ROOT, CONFIG_YAML)
      File.open(file, 'w') { |fh| fh.write YAML.dump(to_hash) }
    end

    def default_values
      {
        img_dir: 'app/assets/img'
      }
    end
  end # class << self
end
