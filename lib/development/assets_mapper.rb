require_relative 'assets_mapper/pull'
require_relative 'assets_mapper/producer'
# Used by rake tasks, map `config.yml` file, update local js/css files, or
# compile minimized version of assets for production use.
# rubocop:disable MethodLength
module AssetsMapper
  ROOT = ENV['APP_ROOT']
  MAPPING_FILE = 'app/assets/mappings.rb'
  PULL_DIR = File.join(Dir.home, '.assets_mappings')

  class << self
    attr_accessor :root, :mapping_file, :pull_dir
  end

  # Parsing and load configurations from mappings.rb
  class Loader
    def initialize(root = ROOT, file = MAPPING_FILE)
      AssetsMapper.root, AssetsMapper.mapping_file = root, file
      AssetsMapper.pull_dir = PULL_DIR
      @mapping_file = File.join(AssetsMapper.root, AssetsMapper.mapping_file)
      fail 'assets mapping file '\
           "#{@mapping_file} not found" unless File.exist?(@mapping_file)

      # load the current configuration yaml (config/assets.yml)
      AssetsSettings.load_yaml
      @settings, @files = AssetsSettings.settings, {}

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
    end

    def execute!(command)
      @command = command
      instance_eval File.read(@mapping_file), @mapping_file
      AssetsSettings.update_yaml!
    end

    # DSL implementation
    def pull(app_name, opts = {})
      to = opts.extract_args(to: PULL_DIR)
      Pull.new(app_name, to, opts).update! unless map?
    end

    def pull_dir(dir = nil)
      AssetsMapper.pull_dir = dir unless dir.nil?
      AssetsMapper.pull_dir
    end

    def produce(file_id, opts = {}, &prc)
      puts "Produce ---- | #{file_id} | --------------------"
      @files[file_id] ||= Producer.new(file_id, opts)
      @files[file_id].command = @command
      @files[file_id].instance_eval(&prc)
    end

    private

    def update?
      @command == :update
    end

    def map?
      @command == :map
    end

    def compile?
      @command == :compile
    end
  end
end
