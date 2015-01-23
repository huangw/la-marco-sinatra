require 'yaml'
require 'fileutils'
require 'development/i18n_updator'
require 'utils/hash_flatter'
include HashFlatter

namespace :i18n do
  desc 'update i18n files for template files'
  task :uv do
    supported_locales = %w(en ja zh).map(&:to_sym)
    view_dir = root_join('app/views')
    i18n_dir = root_join('i18n/views')

    cur_trans_files = {} # keep a global yaml contents table
    Dir["#{view_dir}/**/*.slim"].each do |vfile|
      idir = File.dirname(vfile.sub(/\A#{view_dir}/, i18n_dir))
      scope = idir.sub(/#{i18n_dir}\/?/, '').split('/').join('.')
      scope += ".#{File.basename(vfile, '.slim')}"

      FileUtils.mkdir_p(idir) unless File.exist?(idir)

      # read the slim file, extract keys
      keys = I18nUpdator.fetch_view_keys(File.open(vfile))
      puts "parsing #{vfile.sub(/\A#{view_dir}\/?/, '')}, got: '#{keys.join(', ')}'"

      supported_locales.each do |locale|
        yml_file = File.join(idir, "#{locale}.yml")
        puts "updating #{File.basename(yml_file)}"

        # load the current definition hash:
        cur_trans = {}
        cur_trans = hash_join(YAML.load_file(yml_file)) if File.exist?(yml_file)
        cur_trans_files[yml_file] ||= cur_trans # flattered

        keys.map(&:to_sym).each do |k|
          key = "#{locale}." + scope + ".#{k}"
          next if cur_trans_files[yml_file][key]

          default_trans = I18nUpdator.to_human(k)
          unless locale == :en
            puts "retrieve translation for #{k} (#{locale}): "
            default_trans = I18nUpdator.gtrans(default_trans, locale)
            puts default_trans
          end
          cur_trans_files[yml_file][key] = default_trans
        end
      end
    end

    # write back to the yaml files
    cur_trans_files.each do |file, contents|
      chash = {}
      contents.each do |key, value|
        chash.deep_merge! hash_nest(key.split('.'), value).deep_symbolize_keys
      end
      File.open(file, 'w') { |fh| fh.write YAML.dump(chash) }
    end
  end

  desc 'start iye translation server'
  task :iye do
    exec 'bundle exec iye ./i18n'
  end
end
