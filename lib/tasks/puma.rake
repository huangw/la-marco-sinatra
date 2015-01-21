desc 'start a puma powered server'
task :server do
  exec('puma --port 8080 --pidfile tmp/puma.pid')
end
task s: :server
