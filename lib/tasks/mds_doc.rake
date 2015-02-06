# encoding: utf-8
require 'fileutils'

# Render markdown document with spec / docco extensions
class SpecDocument
  # Valid options are:
  #  - mdoconly: skip all spec test document generation
  #  - force: force re-generate all spec document even the file is newer
  def initialize(src, out, opts = {})
    @src, @mdoconly, @force = src, opts[:mdoconly], opts[:force]
    @dir = File.join(out, 'spec')
    fail "source file #{@src} not found" unless File.exist?(src)
  end

  def render
    wfh = File.open(@src.gsub('.md', '.render.md'), 'wb')
    $stderr.puts "rendering #{@src}"
    File.open(@src).each_with_index do |line, ln|
      if match = line.match(/spec:\s*(?<target>[\w\/]+)/)
        target = match[:target].gsub(/\.rb\Z/, '')
        $stderr.puts "  - (line #{ln}): #{target}"
        fail "target file for #{target}.rb not found" unless File.exist?(target + '.rb')
        sstr = "[`#{target}.rb`](./spec/#{src_file(target)}) "
        spec_rslt = test_file(target)
        spec_html = test_src(target)
        sstr += "(RSpec [src](./spec/#{spec_html}) [rslt](./spec/#{spec_rslt}))" if spec_html
        line = line.sub(/spec:\s*[\w\/]+/, sstr)
      end

      line = line.gsub('TODO:', '<strong style="color: red">[TODO]</strong>')
      wfh.write line
    end
    wfh.close
  end

  def newer?(src, tgt)
    return true if @force
    fail 'source file not exists' unless File.exist?(src)
    return true unless File.exist?(tgt)
    File.mtime(src) > File.mtime(tgt)
  end

  def src_file(target)
    source_file = target + '.rb'
    output_file = File.join(@dir, target.gsub(/\Aapp/, '') + '.html')
    if newer?(source_file, output_file)
      dir = File.dirname(output_file)
      FileUtils.mkdir_p dir unless File.directory?(dir)
      `docco #{source_file} --output #{File.dirname(output_file)}`
    end
    output_file.gsub(/\A#{@dir}\//, '')
  end

  def test_src(target)
    rspec_file = target.sub(/\Aapp\/?/, '')
    rspec_file = File.join('spec', "#{rspec_file}_spec.rb")
    return false unless File.exist?(rspec_file)

    output_file = File.join(@dir, target.gsub(/\Aapp/, '') + '_spec.html')
    if newer?(rspec_file, output_file)
      dir = File.dirname(output_file)
      FileUtils.mkdir_p dir unless File.directory?(dir)
      `docco #{rspec_file} --output #{File.dirname(output_file)}`
    end
    output_file.gsub(/\A#{@dir}\//, '')
  end

  def test_file(target)
    rspec_file = target.sub(/\Aapp\/?/, '')
    rspec_file = File.join('spec', "#{rspec_file}_spec.rb")
    return false unless File.exist?(rspec_file)
    output_file = File.join(@dir, target.gsub(/\Aapp/, '') + '_spec_rslt.html')
    if !@mdoconly && newer?(rspec_file, output_file)
      dir = File.dirname(output_file)
      FileUtils.mkdir_p dir unless File.directory?(dir)
      `rspec #{rspec_file} --format html > #{output_file}`
    end
    output_file.gsub(/\A#{@dir}\//, '')
  end
end

namespace :doc do
  desc 'render MD documents with spec extensions'
  task :mds do
    mds_dir = ENV['MDS_DIR'] || 'mds'
    out_dir = ENV['OUT_DIR'] || 'doc'
    opts = {}
    opts[:force] = true if ENV['FORCE']
    opts[:mdoconly] = true if ENV['MDOCONLY']

    Dir[mds_dir + '/*.md'].each do |md|
      next if md.match(/\.render\./)
      if md.match(/api\.md\Z/)
        puts "skip API documentation #{md}"
        next
      end
      SpecDocument.new(md, out_dir, opts).render
      sh "mdoc #{md.sub(/\.md\Z/, '.render.md')}"
      puts "#{md.sub(/\.md\Z/, '.html').sub('mds', out_dir)} created"
      FileUtils.mv md.sub(/\.md\Z/, '.render.html'), md.gsub('.md', '.html')
      FileUtils.mv md.sub(/\.md\Z/, '.html'), out_dir
      FileUtils.rm md.sub(/\.md\Z/, '.render.md')
    end
  end
end
