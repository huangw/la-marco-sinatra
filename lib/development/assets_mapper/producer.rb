require_relative 'vendor'
require_relative 'cloud'
# AssetsMapper namespace
module AssetsMapper
  # produce a file
  class Producer
    attr_accessor :command
    attr_reader :file_type

    def initialize(file_id, opts = {})
      @file_id = file_id
      @file_type = opts.extract_args(type: nil)
      @file_type = 'js' if @file_id.match(/\.js\Z/)
      @file_type = 'css' if @file_id.match(/\.css\Z/)

      fail "file type must be js or css" unless %w(js css).include?(@file_type)

      AssetsSettings[:development][@file_id].urls = [] # reset urls

      min_dir = AssetsSettings[:production].min_dir
      @minimize_to = opts.extract_args!(minimize_to: min_dir)
      @compile_list = []

      # if compile?
      #   AssetsSettings[:local_assets][self.file_id].url = [] # reset urls
      #   AssetsSettings[:production][self.file_id].url = [] # reset urls
      # end
    end

    # this is the target file setting in global space and can << url to
    def urls(env)
      AssetsSettings[env][@file_id]
    end

    def vendor(sfile, opts = {})
      vendor_file = Vendor.new(sfile, @file_type, opts)
      vendor_file.copy! unless map?
      @compile_list << vendor_file.to
      urls(:development) << vendor_file.to
    end

    def cloud(url, opts = {})
      urls(:production) << url if compile?
      cloud_file = Cloud.new(url, @file_type, opts)
      cloud_file.download! unless map?
      urls(:development) << cloud_file.to
      urls(:local_assets) << cloud_file.to
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

