# asset mapper module class
module AssetMapper
  # Handler for the produce block, create a Tfile from a series of
  # Sfile (and CloudFile, VendorFile)
  class Producer
    attr_reader :tfile, :sfiles
    def initialize(file_id)
      @file_id = file_id
      @tfile = Tfile.new(file_id)
      @sfiles = []
      @cloud_files = []
    end

    # DSL command
    # ---------------------------
    def vendor(filename, opts = {})
      vendor_file = VendorFile.new(filename, opts)
      vendor_file.copy!
      @sfiles << vendor_file
      @tfile.compile_files << vendor_file.abs_path
    end

    def cloud(url, opts = {})
      cloud_file = CloudFile.new(url, opts)
      cloud_file.download!
      @sfiles << cloud_file
      @cloud_files << cloud_file
    end

    def file(filename)
      sfile = Sfile.new(filename)
      raise "file #{sfile.file_path} "\
           'does not exists' unless File.exist?(sfile.abs_path)
      @sfiles << sfile
      @tfile.compile_files << sfile.abs_path
    end

    # Update AssetSettings
    # ---------------------
    # rubocop:disable LineLength
    def update_asset_settings!
      AssetSettings[:development].files[@file_id] = @sfiles.map(&:local_url)
      return unless AssetMapper.compile?

      AssetSettings[:production].files[@file_id] = @cloud_files.map(&:production_url)
      AssetSettings[:production].files[@file_id] << @tfile.production_url if @tfile.production_url

      AssetSettings[:local_assets].files[@file_id] = @cloud_files.map(&:local_url)
      AssetSettings[:local_assets][@file_id] << @tfile.local_url if @tfile.local_url
    end
  end
end
