# An asset mapper class
module AssetMapper
  # Cloud file to download
  class CloudFile < Sfile
    def initialize(url, opts = {})
      @url = url
      @filename = File.basename(@url.to_s)
      @to, @upd = opts.extract_args! cache_to: nil, update: true
      @to ||= File.join(AssetMapper.cloud_dir, URI(@url).host)
    end

    def file_path
      File.join(@to, filename)
    end

    def production_url
      @url if @url
    end

    def update?
      @upd ? true : false
    end

    def download!
      return dl_file!(@url, abs_path) unless File.exist?(abs_path)
      return puts("Skip #{@url}, as update == false") unless update?
      dl_file!(@url, abs_path)
    end

    private

    def dl_file!(url, tfile)
      puts "download '#{url}'\n"\
           "      -> '#{file_path}"
      tdir = File.dirname(tfile)
      FileUtils.mkdir_p tdir unless File.exist?(tdir)
      Net::HTTP.start(URI(@url).host) do |http|
        res = http.get(@url)
        open(tfile, 'wb') { |fh| fh.write(res.body) }
      end
    end
  end
end
