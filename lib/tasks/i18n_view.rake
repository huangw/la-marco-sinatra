require 'development/i18n_utils'
namespace :i18n do
  namespace :update do
    desc 'update i18n messages for templates (app/views)'
    task :views do
      view_dir, i18n_dir = 'app/views', 'i18n/views'
      Dir["#{view_dir}/**/*.slim"].each do |vfile|
        idir = File.dirname(vfile.sub(/\A#{view_dir}/, i18n_dir))
        page_name = File.basename(vfile, '.slim')
        page_scope = idir.sub(/#{i18n_dir}\/?/, '').split('/')
        page_scope << page_name

        fkeys = I18nUtils.find_tt_keys(File.open(vfile).each.to_a).uniq.dup

        I18n.available_locales.each do |lc|
          yml_file = File.join(idir, "#{lc}.yml")
          flc = I18nUtils::YamlFile.new(yml_file)
          fkeys.each do |k|
            key_scope = page_scope.dup.unshift lc
            key_scope << k
            scope_key = flc.scope_join(*key_scope)
            depth = -1
            depth = -2 if scope_key.match(/title\Z/)
            depth = -3 if scope_key.match(/index\.title\Z/)
            flc.add_with_gt(scope_key, depth)
          end
          flc.rewrite!
        end
      end
    end
  end
  desc 'shortcut for update:views'
  task :uv => [:'update:views']
end
