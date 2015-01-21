desc 'start/restart a puma powered server'
task :server do
  if File.exist?('tmp/puma.pid')
    puts "puma running, restart"
    pid = File.read('tmp/puma.pid')
    sh "kill -USR2 #{pid}"
  else
    File.mkdir 'tmp' unless File.exist?('tmp')
    exec('puma --port 8080 --pidfile tmp/puma.pid')
  end
end
task s: :server
