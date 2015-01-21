desc 'start/restart a puma powered server'
task :server do
  if File.exist?('tmp/puma.pid')
    puts "puma running, restart"
    pid = File.read('tmp/puma.pid').chomp.to_i
    begin
      Process.getpgid( pid )
      sh "kill -USR2 #{pid}"
    rescue Errno::ESRCH
      File.rm('tmp/puma.pid')
      exec('puma --port 8080 --pidfile tmp/puma.pid')
    end
  else
    File.mkdir 'tmp' unless File.exist?('tmp')
    exec('puma --port 8080 --pidfile tmp/puma.pid')
  end
end
task s: :server
