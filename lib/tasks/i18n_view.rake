require 'devtools/i18n_utils'
namespace :i18n do
  namespace :update do
    desc 'update i18n messages for templates (app/views)'
    task :views do
      view_dir, i18n_dir, lcs = 'app/views', 'i18n/views', [:en, :ja, :zh]
      dirs = Dir["#{view_dir}/**/*"].to_a.select { |f| File.directory?(f) }

      dirs.each do |dir|
        keys, idir = [], dir.sub(/\A#{view_dir}/, i18n_dir)
        dir_name = dir.sub(/#{view_dir}\/?/, 'views.').split('/').join('.')
        # add index for directory, even there is no index template here
        keys << "#{dir_name}.index.title"
        Dir["#{dir}/*.slim"].each do |vfile|
          # skip partial page
          next if vfile.match(/\A\_/)
          # skip already localized page
          next if vfile.match(/\.(#{lcs.map(&:to_s).join('|')})\.slim\Z/)
          page_name = File.basename(vfile, '.slim')
          # title for the template page
          keys << "#{dir_name}.#{page_name}.title"
          I18nUtils.find_tt_keys(File.open(vfile).each.to_a).each do |k|
            keys << "#{dir_name}.#{page_name}.#{k}"
          end
        end

        fkeys = keys.uniq.dup
        lcs.each do |lc|
          yml_file = File.join(idir, "#{lc}.yml")
          flc = I18nUtils::YamlFile.new(yml_file)
          fkeys.each do |k|
            depth = -1
            depth = -2 if k.match(/title\Z/)
            depth = -3 if k.match(/index\.title\Z/)
            flc.add_with_gt("#{lc}.#{k}", depth)
          end
          flc.rewrite!
        end
      end # dirs.each do
    end
  end
  desc 'shortcut for update:views'
  task :uv => [:'update:views']
end
