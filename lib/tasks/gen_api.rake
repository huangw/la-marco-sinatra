require 'devtools/file_generator'

# Helper for rake to generate source files
class FileGenerator
   # API controller file generator
  class ApiFile < RubyFile
    def initialize(name, su = nil)
      @filename = name.to_s.underscore.sub(/\Aapp\/pages\/api\//, '')
      super "app/pages/api/#{@filename}", su
    end

    def spec_name
      "'#{@filename.sub(/\Aapp\/pages/, '').sub(/\.rb\Z/, '')}'"
    end
  end
end

namespace :gen do
  desc 'generate api controller and spec file for NAME'
  task :api do
    name = ENV['NAME'] || ENV['name']
    super_class = ENV['SUPER'] || ENV['super'] || 'restful_api'
    fail 'need specify NAME=...' unless name
    rf = FileGenerator::RubyFile.new(name, super_class)
    rf.render! controller_file: rf.filename, spec_file: rf.spec_filename
  end
end

__END__

@@ controller_file
# [Controller] <%= spec_name %>
#   (<%= filename %>)
# vim: foldlevel=1
# created at: <%= Time.now.strftime('%F') %>

# API controller for <%= spec_name %>
class <%= class_string %>
  get '/' do
  end

  Route << self
end

@@ spec_file
require 'spec_helper'
require '<%= require_name %>'

describe <%= spec_name %> do
  describe 'TODO: the function of this route [GET]' do
    it 'TODO: an actual acess test' do
    end
  end
end
