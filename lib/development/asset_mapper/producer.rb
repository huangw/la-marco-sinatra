# asset mapper module class
module AssetMapper
  # Handler for the produce block, create a Tfile from a series of
  # Sfile (and CloudFile, VendorFile)
  class Producer
    attr_reader :tfile, :sfiles
    def initialize(file_id)
      @tfile = Tfile.new
      @sfile = []
    end

    # DSL command
    # ---------------------------
    def vendor(url, opts = {})
    end

    def cloud(url, opts = {})
    end

    def file(filename)
    end
  end
end
