require 'pry-byebug'
desc 'invoke an interactive console'
task :console do
  binding.pry
end

task c: :console
