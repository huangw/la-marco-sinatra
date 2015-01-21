# Mixin into Object for dynamic library file requirements

# require a file if it exists, return true if the file exists
def try_require(file, rel_path = nil)
  file = File.expand_path(file, rel_path) if rel_path
  return false unless File.exist?(file.sub(/\.rb\Z/, '.rb'))
  require file || true # return true if file
end

def deep_require(dir, rel_path = nil, deepth = 3)
  dir = File.expand_path(dir, rel_path) if rel_path
  (i..deepth).each { |i| Dir["#{dir}#{'/*' * i}.rb"].each { |f| require f } }
end
