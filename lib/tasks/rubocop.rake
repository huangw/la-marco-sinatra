require 'rubocop/rake_task'
desc 'Run rubocop for local directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['{app,config,lib}/**/*.rb']
  task.fail_on_error = false
end

desc 'Run rubocop auto correct'
task rac: :'rubocop:auto_correct'
