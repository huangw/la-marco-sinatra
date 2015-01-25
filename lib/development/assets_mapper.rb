require_relative 'assets_mapper/loader'

# assets mapping tools
module AssetsMapper
  # mappings as the entry point
  class << self
    attr_accessor :config

    def map!(root = ENV['APP_ROOT'])
      AssetsMapper.config = AssetsConfig.new(root)
      Loader.new(root, file).load!(:map)
    end

    def update!(root = ENV['APP_ROOT'])
      AssetsMapper.config = AssetsConfig.new(root)
      Loader.new(root, file).load!(:update)
    end

    def compile!(root = ENV['APP_ROOT'])
      AssetsMapper.config = AssetsConfig.new(root)
      Loader.new(root, file).load!(:compile)
    end
  end
end
