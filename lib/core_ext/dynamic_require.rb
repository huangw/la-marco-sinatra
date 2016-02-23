# Mixin into Object for dynamic library file requirements

# require a file if it exists, return true if the file exists
def try_require(file)
  return false unless File.exist?(file.sub(/\.rb\Z/, '') + '.rb')
  require file || true # return true if file
end

# require all files in a directory recursively, shallow ones first
def deep_require(dir, deepth = 3)
  (1..deepth).each { |i| Dir["#{dir}#{'/*' * i}.rb"].each { |f| require f } }
end

# require all files specified by the pattern
def require_all(pattern)
  Dir[pattern].each { |f| require f }
end
