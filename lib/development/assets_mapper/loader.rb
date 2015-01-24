require_relative 'pull'
# mix-in the name space
module AssetsMapper
  # DSL command available directly in the mapping ruby file, top scope
  class Loader
    def initialize(root, file = nil)
      @root = root
      @mapping_file = file if file
      default_values.each do |met, default|
        instance_variable_set("@#{met}", default)  # set default value
        define_singleton_method met do |val = nil| # a getter/setter
          instance_variable_set("@#{met}", val) unless val.nil?
          instance_variable_get("@#{met}")
        end
      end
    end

    def load(command = :update)
      @command = command
      rfile = File.join(root, mapping_file) # create absolute path
      instance_eval File.read(rfile), rfile
    end

    # Global DSL implementations
    # ------------------------------
    def pull(app_name, opts)
      return false unless @command == :update
      to = opts.extract_args(to: pull_dir)
      Pull.new(app_name, to, opts).update!
    end

    private

    def default_values
      {
        root: ENV['APP_ROOT'],
        mapping_file: 'app/assets/mappings.rb',
        pull_dir: File.join(Dir.home, '.assets_mappings')
      }
    end
  end
end
