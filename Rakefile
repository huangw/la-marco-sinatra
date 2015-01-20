require_relative 'config/boot'

require 'rake'
Dir.glob('lib/tasks/*.rake').each { |r| import r }

desc 'Create or Update ctags file'
task :ctags do
  sh 'ctags -R --exclude=*.js .'
end

task default: [:ctags, :rubocop, :spec]
