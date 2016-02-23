def example_file(arg)
  File.join(ENV['APP_ROOT'], 'spec/support/examples', arg)
end
