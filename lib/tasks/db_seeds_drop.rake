# encoding: utf-8

namespace :db do
  desc 'seeds the database from db/seed.rb'
  task :seeds do
    ENV['SEED_FILES'] ||= ENV['APP_ROOT'] + '/db/*seed.rb'
    Dir[ENV['SEED_FILES']].each do |f|
      puts "loading #{f}"
      load f
    end
  end

  desc 'drop the whole database'
  task :drop do
    fail 'add confirm to confirm delete' unless ENV['CONFIRM']
    puts 'drop default mongoid session in 5 secounds (Ctrl-C to cancel): '
    p ::Mongoid::Clients.default.database.name
    sleep 5
    ::Mongoid::Clients.default.database.drop
  end
end
