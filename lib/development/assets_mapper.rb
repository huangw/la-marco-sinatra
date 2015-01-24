# assets mapping tools
module AssetsMapper
  # mappings as the entry point
  class Mappings
    def initialize(root = ENV['APP_ROOT'])
      @root = root
      [:root].each do |met|
        define_singleton_method met do |val = nil|
          instance_variable_set("@#{met}", val) unless val.nil?
          instance_variable_get("@#{met}")
        end
      end
    end

    def load(file = 'app/assets/mappings.rb')
      @mapping_file = File.join(root, 'app/assets/mappings.rb')
      instance_eval File.read(@mapping_file), @mapping_file
    end
  end
end
