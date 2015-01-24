require_relative 'assets_mapper/loader'

# assets mapping tools
module AssetsMapper
  # mappings as the entry point
  class << self
    def update!(root = ENV['APP_ROOT'], file = nil)
      Loader.new(root, file).load(:update)
    end
  end
end
