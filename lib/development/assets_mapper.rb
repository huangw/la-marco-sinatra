# Used by rake tasks, map `config.yml` file, update local js/css files, or
# compile minimized version of assets for production use.
# rubocop:disable MethodLength
module AssetsMapper
  ROOT = ENV['APP_ROOT']
  MAPPING_FILE = 'app/assets/mappings.rb'

  # Parsing and load configurations from mappings.rb
  class Loader
    def initialize(root = ROOT, file = MAPPING_FILE)
      @mapping_file = File.join(root, file)
      fail 'assets mapping file '\
           "#{@mapping_file} not found" unless File.exist?(@mapping_file)

      # load the current configuration yaml (config/assets.yml)
      @settings = AssetsSettings.load_yaml.settings

      # set dsl for global vars
      AssetsSettings.default_values.keys.each do |met|
        define_singleton_method met do |val = nil|
          if val.is_a?(Hash)
            val.keys.each do |k|
              fail 'unknown environment '\
                   "'#{k}'" unless AssetsSettings.environments.include?(k)
            end
          end

          AssetsSettings.environments.each do |env|
            env_val = val.is_a?(Hash) ? val[env] : val.dup
            AssetsSettings[env].send(met, env_val)
          end
        end
      end

      instance_eval File.read(@mapping_file), @mapping_file
    end

    # DSL implementation
    def setup_global_vars_dsl

    end

    #
  end
end
