require 'devtools/i18n_utils'
namespace :i18n do
  desc 'start iye translation server'
  task :iye do
    exec 'bundle exec iye ./i18n'
  end

  namespace :update do
    desc 'update i18n messages for exceptions'
    task :exceptions do
      # find keys from all local ruby files
      ENV['FILES'] ||= '{app,lib,config}/**/*.rb'
      keys = []
      Dir[ENV['FILES']].each do |f|
        I18nUtils.find_fail_keys(File.open(f).each.to_a).each { |k| keys << k }
      end

      fkeys = keys.uniq.dup
      [:en, :ja, :zh].each do |lc|
        flc = I18nUtils::YamlFile.new("i18n/exceptions/#{lc}.yml")
        fkeys.each { |k| flc.add_with_gt("#{lc}.exceptions.#{k}") }
        flc.rewrite!
      end
    end
  end

  desc 'shortcut for update:exceptions'
  task ue: [:'update:exceptions']
end
