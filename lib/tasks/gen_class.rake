require 'devtools/file_generator'

namespace :gen do
  desc 'generating general ruby class/spec file from NAME'
  task :ruby do
    name = ENV['NAME'] || ENV['name']
    super_class = ENV['SUPER'] || ENV['super']
    raise 'need specify NAME=...' unless name
    rf = FileGenerator::RubyFile.new(name, super_class)
    rf.render! class_file: rf.filename, spec_file: rf.spec_filename
  end
end

__END__

@@ class_file
# [Class] <%= class_name %>
#   (<%= filename %>)
# vi: foldlevel=1
# created at: <%= Time.now.strftime('%F') %>

# Class for
class <%= class_string %>
end

@@ spec_file
require 'spec_helper'
require '<%= require_name %>'

describe <%= spec_name %> do
end
