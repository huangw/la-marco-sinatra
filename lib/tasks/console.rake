require 'pry'

desc 'invoke an interactive console'
task :console do
  # rubocop:disable Debugger
  binding.pry
end

task c: :console
