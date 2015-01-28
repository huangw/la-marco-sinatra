require 'cucumber'
require 'cucumber/rake/task'

desc 'run cucumber test for all features'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = 'features --format pretty'
end

desc 'alias for :features'
task f: :features

desc 'run cucumber test with chrome driver'
task :cc do
  ENV['DRIVER'] = 'chrome'
  Rake::Task[:features].invoke
end

desc 'create cucumber test reports'
task :accept do
  sh 'bundle exec cucumber features --format=html > doc/cucumber.html'
end
