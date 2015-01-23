namespace :i18n do
  desc 'start iye translation server'
  task :iye do
    exec 'bundle exec iye ./i18n'
  end
end
