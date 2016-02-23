require 'diffy'
# An asset mapper class
module AssetMapper
  # Vendor file to copy from a third party repository
  class VendorFile < Sfile
    def initialize(file_id, opts = {})
      @file_id = file_id
      @from, @to, @upd = opts.extract_args! from: nil, to: nil, update: true
      raise 'use `from` to specify repository to copy from' unless @from
      @filename = File.basename(@file_id)
      @to ||= File.join(AssetMapper.vendor_dir, @from.to_s)
    end

    def update?
      @upd ? true : false
    end

    def file_path
      File.join(@to, filename)
    end

    # rubocop:disable CyclomaticComplexity, MethodLength
    def copy!
      sfile = File.join(repo_path(@from), @file_id)
      raise "file '#{sfile}' not exists" unless File.exist?(sfile)
      raise "'#{sfile}' is a directory" if File.directory?(sfile)

      return copy_file!(sfile, abs_path) unless File.exist?(abs_path)
      return puts("Skip '#{sfile}', as update == false") unless update?
      return puts("skip '#{sfile}', target file"\
                  ' is identical') if File.identical?(sfile, abs_path)

      diff = diff_file(sfile, abs_path)
      return puts("Skip, '#{sfile}' and the target file have same "\
                  'contents') if diff && diff.to_s.chomp.empty?

      copy_file!(sfile, abs_path, diff)
    end

    private

    def copy_file!(sfile, tfile, diff = nil)
      puts "copy '#{sfile}'\n"\
           "  -> '#{file_path}'"
      if diff && !diff.to_s.chomp.empty?
        puts '-----------------------------------'
        puts diff.to_s(:color)
        puts '-----------------------------------'
      end

      tdir = File.dirname(tfile)
      FileUtils.mkdir_p tdir unless File.exist?(tdir)
      FileUtils.cp sfile, tfile
    end

    def diff_file(sfile, tfile)
      Diffy::Diff.new(tfile, sfile, source: 'files', context: 3)
    end

    def repo_path(from)
      case from
      when Symbol then File.join(AssetMapper.pull_dir, from.to_s)
      when String then File.expand_path(from)
      end
    end
  end
end
