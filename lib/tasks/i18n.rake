require 'yaml'
require 'fileutils'
namespace :i18n do
  desc 'create initial i18n yaml files'
  task :create do
    fail 'you need specify ENV["name]' unless ENV['name']
    dir = root_join('i18n', ENV['name'])

    fail "directory #{dir} already exists" if File.exist?(dir)
    FileUtils.mkdir_p dir

    %w(en ja zh).each do |lname|
      File.open(File.join(dir, "#{lname}.yml"), 'w') do |fh|
        fh.write YAML.dump(lname.to_sym => { title: '' })
      end
    end
  end

  desc 'start iye translation server'
  task :iye do
    exec 'bundle exec iye ./i18n'
  end
end
