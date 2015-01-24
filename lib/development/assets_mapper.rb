require_relative 'assets_mapper/mapping_dsl'

# assets mapping tools
module AssetsMapper
  # mappings as the entry point
  class Mappings
    include MappingDSL

    def initialize(root = ENV['APP_ROOT'])
      @root = root
      default_values.each do |met, default|
        instance_variable_set("@#{met}", default)  # set default value
        define_singleton_method met do |val = nil| # a getter/setter
          instance_variable_set("@#{met}", val) unless val.nil?
          instance_variable_get("@#{met}")
        end
      end
    end

    def load(file = nil)
      @mapping_file = file if file # use the user specified
      rfile = File.join(root, mapping_file) # create absolute path
      instance_eval File.read(rfile), rfile
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
