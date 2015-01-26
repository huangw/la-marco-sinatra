require_relative 'vendor'
require_relative 'cloud'
require 'sass'
require 'closure-compiler'

# AssetsMapper namespace
module AssetsMapper
  # produce a file
  class Producer
    attr_reader :file_type, :compile_list

    def initialize(file_id, opts = {})
      @file_id = file_id
      @file_type = opts.extract_args(type: nil)
      @file_type = 'js' if @file_id.match(/\.js\Z/)
      @file_type = 'css' if @file_id.match(/\.css\Z/)

      fail "file type must be js or css" unless %w(js css).include?(@file_type)

      AssetsSettings[:development][@file_id].urls = [] # reset urls
      if compile?
        AssetsSettings[:production][@file_id].urls = []
        AssetsSettings[:local_assets][@file_id].urls = []
      end

      @current_min_file = AssetsSettings[:local_assets][@file_id].urls.last
      @current_min_url = AssetsSettings[:production][@file_id].urls.last
      min_dir = AssetsSettings[:production].min_dir
      @minimize_to = opts.extract_args!(minimize_to: min_dir)
      @compile_list = []
    end

    # this is the target file setting in global space and can << url to
    def urls(env)
      AssetsSettings[env][@file_id]
    end

    def vendor(sfile, opts = {})
      vendor_file = Vendor.new(sfile, @file_type, opts)
      vendor_file.copy! unless map?
      @compile_list << vendor_file.to
      urls(:development) << File
        .join(AssetsSettings[:development].assets_url_prefix, vendor_file.to)
    end

    def cloud(url, opts = {})
      urls(:production) << url if compile?
      cloud_file = Cloud.new(url, @file_type, opts)
      cloud_file.download! unless map?
      urls(:development) << cloud_file.to
      urls(:local_assets) << cloud_file.to if compile?
    end

    def file(fname) # no coffee/sass support
      fail "file must with #{file_type} "\
           'extension' unless fname.match(/\.#{file_type}\Z/)
      file = File.join(AssetsSettings[:development].assets_dir, fname)
      abs_file = File.join(AssetsMapper.root, file)
      fail "file #{file} not exists" unless File.exist?(abs_file)
      @compile_list << file
      urls(:development) << file
    end

    def compile!
      new_base_file = file_type == 'js' ? compile_js! : compile_css!
      new_min_file = File.join(@minimize_to, new_min_file)
      abs_new_file = File.join(AssetsMapper.root, new_min_file)
      abs_cur_file = File.join(AssetsMapper.root, @current_min_file)
      if FileUtils.compare_file(abs_new_file, abs_cur_file)
        FileUtils.rm_rf abs_new_file
        AssetsSettings[:local_assets][@file_id].urls << @current_min_file
        AssetsSettings[:production][@file_id].urls << @current_min_url
      else
        AssetsSettings[:local_assets][@file_id].urls << new_min_file
        AssetsSettings[:production][@file_id].urls << File
          .join(AssetsSettings[:production].assets_url_prefix, new_base_file)
      end
    end

    def compile_js!
      basename = @file_id.sub(/\.js\Z/, ".#{Time.now.short}.js")
      file = File.join(AssetsMapper.root, @minimize_to, basename)
      list = @compile_list.map { |f| File.join(AssetsMapper.root, f) }
      File.open(file, 'w') do |fh|
        fh.write Closure::Compiler.new.compile_files(list)
      end
      basename
    end

    def compile_css!
      basename = @file_id.sub(/\.js\Z/, ".#{Time.now.short}.js")
      file = File.join(AssetsMapper.root, @minimize_to, basename)
      list = @compile_list.map { |f| File.join(AssetsMapper.root, f) }
      File.open(file, 'w') do |fh|
        fh.write Sass::Engine.new(file_list.map { |f| File.read(f) }.join,
                                  syntax: :scss, style: :compressed).render
      end
      basename
    end
  end
end

