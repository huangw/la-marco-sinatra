require 'fileutils'

# Helper for rake to generate source files
class FileGenerator
  # Class file generator
  class RubyFile
    attr_reader :filename, :basename, :super_basename
    def initialize(name, su = nil)
      @filename = name.to_s.underscore.sub(/(\.rb)?\Z/, '.rb')
      @basename = File.basename(@filename, '.rb')
      @super_basename = su.to_s.underscore if su
    end

    def spec_filename
      File.join('spec',
                @filename.sub(%r{\A(app/)?}, '').sub(/\.rb\Z/, '_spec.rb'))
    end

    def spec_name
      class_name
    end

    def class_name
      @basename.classify
    end

    def super_classname
      @super_basename.classify
    end

    def require_name
      filename.sub(%r{\Aapp/}, '').sub(%r{\Alib/}, '').sub(/\.rb\Z/, '')
    end

    def class_string
      @super_basename ? class_name << " < #{super_classname}" : class_name
    end

    def find_caller
      caller.each do |str|
        str = str.split(':')[0]
        return str if str =~ /(\.rake|_spec.rb)\Z/
      end
    end

    # rubocop:disable CyclomaticComplexity, MethodLength
    def data_tpl(id)
      data_reached = false
      started = false
      contents = ''
      File.open(find_caller).each do |line|
        if data_reached
          if started
            started = false if line =~ /\A\s*@@\W?/
            contents << line if started
          end
          started = true if line =~ /\A\s*@@\s*#{id}/
        end
        data_reached = true if line =~ /__END__/
      end
      contents.sub(/\A\n*/, '').sub(/\n*\Z/, '') # return
    end

    # render :tmplate_id => :file
    def render!(hsh)
      hsh.each do |tid, file|
        if File.exist?(file)
          puts "skip existing file #{file}"
        else
          tpl = data_tpl(tid)
          FileGenerator.wopen(file).write ERB.new(tpl).result(binding)
        end
      end
    end
  end

  class << self
    def wopen(file, bit = 'wb', &prc)
      dir = File.dirname(file)
      FileUtils.mkdir_p dir unless File.exist?(dir)
      File.open(file, bit, &prc)
    end
  end
end
