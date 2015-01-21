# Mixin into Object for dynamic library file requirements

# require a file if it exists, return true if the file exists
def try_require(file)
  return false unless File.exist?(file.sub(/\.rb\Z/, '') + '.rb')
  require file || true # return true if file
end

def deep_require(dir, deepth = 3)
  (1..deepth).each { |i| Dir["#{dir}#{'/*' * i}.rb"].each { |f| require f } }
end
