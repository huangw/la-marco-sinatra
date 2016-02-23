require 'devtools/file_generator'

# Extend file generator
class FileGenerator
  # Mogoid model extends ruby
  class ModelFile < RubyFile
    def factory_filename
      File.join('spec', 'support', 'factories', "#{basename}_factory.rb")
    end
  end
end

namespace :gen do
  desc 'generating mongoid model file from NAME'
  task :model do
    name = ENV['NAME'] || ENV['name']
    super_class = ENV['SUPER'] || ENV['super']
    fail 'need specify NAME=...' unless name
    name = name.sub(/\Aapp\/models\//, '')
    rf = FileGenerator::ModelFile.new("app/models/#{name}", super_class)
    rf.render! model_file: rf.filename, spec_file: rf.spec_filename
    rf.render! factory_file: rf.factory_filename unless super_class
  end
end

__END__

@@ model_file
# [Model] <%= class_name %> (<%= filename %>)
# vim: foldlevel=1
# created at: <%= Time.now.strftime('%F') %>

# Class for
class <%= class_string %>
  <% unless super_basename %>include Mongoid::Document<% end %>

  # -- | indexes | -------------------
  # ----------------------------------
end

@@ spec_file
require 'spec_helper'

describe <%= spec_name %> do
  subject(:<%= class_name.underscore %>) { <%= class_name %>.new }
end

@@ factory_file
FactoryGirl.define do
  factory :<%= class_name.underscore %> do
  end
end
