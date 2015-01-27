# asset mapper module class
module AssetMapper
  # Parse the assets mappings file and execute rake tasks
  class Loader
    def initialize(file = nil)
      file ||= File.join(AssetMapper.assets_dir, 'mappings.rb')
      @mapping_file = File.join(AssetMapper.root, file)

      # Load the current configuration yaml (config/assets.yml)
      AssetSettings.load_yaml

      # Hold a list of files to produce
      @target_files = {}

      # Set dsl for global vars
      (AssetMapper::DEFAULTS.keys + [:assets_url_prefix]).each do |met|
        define_singleton_method(met) { |val| AssetMapper.send(met, val) }
      end
    end

    def execute!(command)
      @command = command
      fail 'assets mapping file '\
           "#{@mapping_file} not exist" unless File.exist?(@mapping_file)

      instance_eval File.read(@mapping_file), @mapping_file
      AssetSettings.update_yaml!
    end

    # DSL implementations
    # ---------------------
    def pull(app_name, opts = {})
      to = opts.extract_args(to: AssetMapper.pull_dir)
      Pull.new(app_name, to, opts).update! unless map?
    end

    def produce(file_id, opts = {}, &prc)
      puts "Produce ---- | #{file_id} | --------------------"
      @target_files[file_id] ||= Tfile.new(file_id, @command, opts)
      @target_files[file_id].instance_eval(&prc)
    end

    # update img dir settings for each environments in global settings
    def img_dir(val)
      AssetSettings.environments.each { |e| AssetSettings[e].img_dir(val) }
    end

    def img_url_prefix(hsh)
      fail "invalid value #{hsh.inspect}" unless hsh.is_a?(Hash)
      # rubocop:disable LineLength
      prod, local = hsh.extract_args!(production: AssetSettings[:production].img_url_prefix,
                                      local: AssetSettings[:local].img_url_prefix)
      AssetSettings[:production].img_url_prefix = prod
      AssetSettings[:development].img_url_prefix = AssetSettings[:local_assets].img_url_prefix = local
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
