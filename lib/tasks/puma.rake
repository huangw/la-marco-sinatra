require 'fileutils'
namespace :puma do
  ENV['PORT'] ||= '8080'
  ENV['PIDFILE'] ||= 'tmp/puma.pid'

  desc 'start puma server'
  task :start do
    warn 'Puma may already running, '\
         'fire start anyway ...' if File.exist?(ENV['PIDFILE'])
    FileUtils.mkdir 'tmp' unless File.exist?('tmp')
    exec("bundle exec puma --port #{ENV['PORT']} --pidfile #{ENV['PIDFILE']}")
  end

  desc 'restart puma server'
  task :restart do
    if File.exist?(ENV['PIDFILE'])
      pid = File.read(ENV['PIDFILE']).chomp
      sh "kill -USR2 #{pid}"
    else
      warn 'Puma not running, abort.'
    end
  end

  desc 'stop puma server'
  task :stop do
    if File.exist?(ENV['PIDFILE'])
      pid = File.read(ENV['PIDFILE']).chomp
      sh "kill #{pid}"
    else
      warn 'Puma not running, abort.'
    end
  end
end

desc 'start/restart server for development'
task :server do
  if ENV['RACK_ENV'] == 'development'
    puts '---- | Route.table | ' + '-' * 40
    ap Route.table
    puts '-' * 60
  end

  if File.exist?(ENV['PIDFILE'])
    puts 'puma running, restart'
    Rake::Task[:'puma:restart'].invoke
  else
    Rake::Task[:'puma:start'].invoke
  end
end
task s: :server
