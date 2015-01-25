# Configuration binding with `config/assets.yml`
class AssetsConfig
  def initialize(root, yml_file = 'config/assets.yml')
    default_values.each do |met, default|
      instance_variable_set("@#{met}", default)  # set default value
      define_singleton_method met do |val = nil| # a getter/setter
        instance_variable_set("@#{met}", val) unless val.nil?
        instance_variable_get("@#{met}")
      end
    end
    @root = root if root
    load_yaml(yml_file)
  end

  def load_yaml(file = 'config/assets.yml')
  end

  def to_yaml(file = 'config/assets.yml')
  end

  # default values
  def default_values
    {
      root: ENV['APP_ROOT'],
      mapping_file: 'app/assets/mappings.rb',
      pull_dir: File.join(Dir.home, '.assets_mappings')
    }
  end
end
