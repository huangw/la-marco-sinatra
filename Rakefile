require_relative 'config/boot'

require 'rake'
Dir.glob('lib/tasks/*.rake').each { |r| import r }

task default: [:ctags, :rubocop, :spec]
