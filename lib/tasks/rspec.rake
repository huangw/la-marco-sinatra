require 'rspec/core/rake_task'
desc 'Run all (r)spec tests'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--format documentation --color'
end

desc 'Run all (r)spec tests with profile'
RSpec::Core::RakeTask.new(:prof) do |t|
  t.rspec_opts = '--profile --color'
end
