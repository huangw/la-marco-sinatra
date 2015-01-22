require 'pry-byebug'
desc 'invoke an interactive console'
task :console do
  def reload!
    files = $LOADED_FEATURES.select { |f| f =~ /\A#{ENV['APP_ROOT']}/ }
    files.each { |file| load file, true }
  end

  # ap with raw: false (default ap behavior)
  def fap(*arg)
    ap(*arg, raw: false)
  end

  binding.pry
end

task c: :console
