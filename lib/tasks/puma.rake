require 'fileutils'

desc 'restart puma server'
task :puma do
  ENV['PORT'] ||= '8080'
  ENV['PIDFILE'] ||= 'tmp/puma.pid'

  if ENV['RACK_ENV'] == 'development'
    puts '---- | Route.table | ' + '-' * 40
    ap Route.table
    puts '-' * 60
  end

  if File.exist?(ENV['PIDFILE'])
    pid = File.read(ENV['PIDFILE']).chomp
    sh "kill -USR2 #{pid}"
  else
    warn 'Puma not running, need `foreman start`?'
  end
end

task s: :puma
