require 'fileutils'
require 'net/http'
require 'uri'
require 'diffy'
# AssetsMapper namespace
module AssetsMapper
  # produce a file
  class Cloud
    attr_accessor :to

    def initialize(url, file_type, opts = {})
      @url, @file_type = url, file_type
      @to, @upd = opts.extract_args! cache_to: nil, update: true
      @to ||= File.join(AssetsSettings[:development].cloud_dir, URI(@url).host,
                        File.basename(@url.to_s))
    end

    def sync?
      @upd ? true : false
    end

    def download!
      tfile = File.join(AssetsMapper.root, @to)

      return dl_file!(@url, tfile) unless File.exist?(tfile)
      return puts("Skip #{sfile}, marked with update == false") unless sync?
      dl_file!(@url, tfile)
    end

    private

    def dl_file!(url, tfile)
      puts "download '#{url}'\n"\
           "      -> '#{tfile.sub(/\A#{AssetsMapper.root}/, '')}'"
      tdir = File.dirname(tfile)
      FileUtils.mkdir_p tdir unless File.exist?(tdir)
      Net::HTTP.start(URI(@url).host) do |http|
        res = http.get(@url)
        open(tfile, 'wb') { |fh| fh.write(res.body) }
      end
    end

    def update?
      @command == :update
    end

    def map?
      @command == :map
    end

    def compile?
      @command == :compile
    end

    def repo_path(from)
      case from
      when Symbol then File.join(AssetsMapper.pull_dir, from.to_s)
      when String then File.expand_path(from)
      end
    end
  end
end
