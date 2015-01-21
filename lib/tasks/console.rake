desc 'invoke an interactive console'
task :console do
  require 'pry-byebug'
  require 'awesome_print'
  AwesomePrint.pry!
  AwesomePrint.defaults = { indent: 2, raw: true }

  def reload!
    files = $LOADED_FEATURES.select { |f| f =~ /\A#{APP_ROOT}/ }
    files.each { |file| load file, true }
  end

  binding.pry
end

task c: :console
