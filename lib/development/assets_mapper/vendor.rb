require 'fileutils'
require 'diffy'
# AssetsMapper namespace
module AssetsMapper
  # produce a file
  class Vendor
    attr_accessor :to

    def initialize(sfile, file_type, opts = {})
      @sfile, @file_type = sfile, file_type
      warn "[WARN] #{sfile} do not has expected extension "\
           ".#{file_type}" unless sfile.match(/\.(#{file_type})\Z/)

      @from, @to, @upd = opts.extract_args! from: nil, to: nil, update: true
      fail 'use `from` to specify repository to copy from' unless @from
      @to ||= File.join(AssetsSettings[:development].vendor_dir,
                        @from.to_s, File.basename(@sfile))
    end

    def sync?
      @upd ? true : false
    end

    def copy!
      sfile = File.join(repo_path(@from), @sfile)
      tfile = File.join(AssetsMapper.root, @to)

      fail "file #{sfile} not exists" unless File.exist?(sfile)
      return puts("Skip directory #{sfile}") if File.directory?(sfile)

      tfile = File.join(tfile, File.basename(sfile)) if File.directory?(tfile)

      return copy_file!(sfile, tfile) unless File.exist?(tfile)
      return puts("Skip #{sfile}, marked with update == false") unless sync?

      return puts("skip #{sfile}, target file"\
                  ' is identical') if File.identical?(sfile, tfile)

      diff = diff_file(sfile, tfile)
      return puts('Skip, source and target have same '\
                  'contents') unless diff && diff.to_s.chomp.size > 0

      copy_file!(sfile, tfile, diff)
    end

    private

    def copy_file!(sfile, tfile, diff = nil)
      puts "copy '#{sfile}'\n"\
           "  -> '#{tfile.sub(/\A#{AssetsMapper.root}/, '')}'"
      if diff && diff.to_s.chomp.size > 0
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
