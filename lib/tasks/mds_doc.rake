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
        sstr = "【SOURCE】[`#{target}.rb`](./spec/#{src_file(target)}) "
        spec_rslt = test_file(target)
        spec_html = test_src(target)
        sstr += "(RSpec [src](./spec/#{spec_html}) [rslt](./spec/#{spec_rslt}))" if spec_html
        line = line.sub(/spec:\s*[\w\/]+/, sstr)
      end

      # Todo label and task list:
      line = line.gsub('TODO:', '<strong style="color: red">[TODO]</strong>')

      # H/L: high/low priority; C: completed; P: pending
      if m_dat = line.match(/(\s*\-\s*)\[(H|L|C|P)?(.+)?\](.+)/)
        date_str = ''
        if m_dat[3]
          date = Date.parse(m_dat[3].to_s)
          date_str = "[#{date.strftime("%m-%d")}]"
          unless m_dat[2] == 'C' || m_dat[2] == 'P'
            if date < Date.today
              date_str = "<b style='color: red'>#{date_str}</b>"
            elsif date == Date.today
              date_str = "<b style='color: #F7D358'>#{date_str}</b>"
            elsif date < Date.today + 2
              date_str = "<b style='color: #blue'>#{date_str}</b>"
            else
              date_str = "<b>#{date_str}</b>"
            end
          end
        end

        spn = case m_dat[2]
              when 'H' then ['<b>', '</b>']
              when 'L' then ['<span style="color: #999999">', '</span>']
              when 'C' then ['<span style="color: green">', '</span>']
              when 'P' then ['<span style="color: #999999">', '</span>']
              else
                ['<span>', '</span>']
              end
        line = m_dat[1] + date_str + spn[0] + m_dat[4] + spn[1] + "\n"
        if m_dat[2] == 'C' || m_dat[2] == 'P'
          line = m_dat[1] + '<del>' + date_str + spn[0] + m_dat[4] + spn[1] + "</del>\n"
        end
      end

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
    mds_dir = ENV['MDS_DIR'] || 'src/doc'
    out_dir = ENV['OUT_DIR'] || 'doc'
    opts = {}
    opts[:force] = true if ENV['FORCE']
    opts[:mdoconly] = true if ENV['MDOCONLY']

    gen_md = [] # generated md file from erb file
    Dir[mds_dir + '/*.md.erb'].each do |erb|
      md = erb.sub(/\.erb\Z/, '')
      puts "generate mardown file from '#{erb}'"
      File.open(md, 'wb') { |h| h.write ERB.new(File.read(erb)).result(binding) }
      gen_md << md
    end

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

    if File.exist?('README.md')
      sh "mdoc README.md"
      FileUtils.mv 'README.html', out_dir
    end

    gen_md.each { |md| FileUtils.rm md } # drop erb generated markdown files
  end
end
