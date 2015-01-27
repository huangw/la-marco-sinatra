require 'fileutils'
require 'sass'
require 'closure-compiler'

# An  asset mapper class
module AssetMapper
  # Target file to produce
  class Tfile
    # filename without version number, like `application.js`
    attr_reader :file_id, :compiled_path

    def initialize(file_id)
      @file_id = file_id
      warn "[WARN] file type unkown: #{file_id}, "\
           'need to be js or css' unless file_id.match(/\.(js|css)\Z/)
      @compile_files = [] # as absolute paths
    end

    def file_type
      file_id.match(/\.js\Z/) ? 'js' : 'css'
    end

    def js?
      file_type == 'js'
    end

    def css?
      file_type == 'css'
    end

    # Paths and URLs with version
    # ----------------
    # Filename is file id with version number inserted
    def filename(version)
      @file_id.sub(/\.#{file_type}\Z/, ".#{version}.#{file_type}")
    end

    def file_path(version)
      File.join(AssetMapper.min_dir, filename(version))
    end

    def abs_path(version)
      File.join(AssetMapper.root, file_path(version))
    end

    # url for the minimized version, @compiled_path only available after
    # compile (even the current version is used)
    def production_url
      path = compiled_path || current_file_path
      File.join(AssetMapper.assets_url_prefix[:production],
                File.basename(path)) if path
    end

    def local_url
      path = compiled_path || current_file_path
      File.join(AssetMapper.assets_url_prefix[:local], path) if path
    end

    # Last version existing
    # -----------------------
    # filename for the minimized file, relative to root
    # Find from the current :local_assets setting
    def current_file_path
      AssetSettings[:local_assets][@file_id].last
    end

    def current_abs_path
      File.join(AssetSettings.root, current_file_path) if current_file_path
    end

    def current_file_version
      file_version(current_file_path) if current_file_path
    end

    def current_file_timestamp
      file_timestamp(current_file_path) if current_file_path
    end

    # Compile
    # -----------
    # return current_file_path if the compiled version has the
    # same contents with the current minimized file,
    # otherwise return the newly minimiazed file path
    def compile!
      new_version = generate_version
      new_abs_path = abs_path(new_version)
      js? ? compile_js!(new_abs_path) : compile_css!(new_abs_path)
      if FileUtils.identical?(new_abs_path, current_abs_path)
        puts "file not changed, use current file (#{current_file_path})"
        @compiled_path = current_file_path
      else
        puts "new file version (#{file_path(new_version)}) created"
        @compiled_path = file_path(new_version)
      end
    end

    def compile_js!(new_path)
      File.open(new_path, 'w') do |fh|
        fh.write Closure::Compiler.new.compile_files(@compile_files)
      end
    end

    def compile_css!(new_path)
      File.open(new_path, 'w') do |fh|
        fh.write Sass::Engine.new(@compile_files.map { |f| File.read(f) }.join,
                                  syntax: :scss, style: :compressed).render
      end
    end

    private

    def generate_version
      Time.now.short
    end

    def version_to_time(version)
      Time.from(version)
    end

    # Extract minimized file version from filename
    # (or file_path, or abs_path)
    def file_version(fname)
      fname.split('.')[-2]
    end

    def file_timestamp(fname)
      version_to_time(file_version(fname))
    end
  end
end
