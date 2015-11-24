require 'pry-byebug'
require 'awesome_print'
AwesomePrint.pry!
AwesomePrint.defaults = { indent: 2 }

def reload!
  files = $LOADED_FEATURES.select { |f| f =~ /\A#{ENV['APP_ROOT']}\/app/ }
  files.each { |file| load file, true }
end

# ap with raw: false (default ap behavior)
def fap(*arg)
  ap(*arg, raw: false)
end
