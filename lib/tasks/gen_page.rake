require 'devtools/file_generator'

# Helper for rake to generate source files
class FileGenerator
  # API controller file generator
  class ControllerFile < RubyFile
    def initialize(name, su = nil)
      @filename = name.to_s.underscore
                      .sub(/\Aapp\/pages\//, '')
                      .sub(/\.rb\Z/, '')
      filepath += '_page' unless @filename.match((/_(api|page|controller)\Z/))
      su ||= 'WebController'
      super "app/pages/#{filepath}", su
    end

    def pathname
      Route.default_path(class_name)
    end

    def feeture_filename
      File.join('features', "#{pathname}.feature")
    end
  end
end

namespace :gen do
  desc 'generate api controller and spec file for NAME'
  task :page do
    name = ENV['NAME'] || ENV['name']
    super_class = ENV['SUPER'] || ENV['super'] || 'restful_api'
    fail 'need specify NAME=...' unless name
    rf = FileGenerator::ControllerFile.new(name, super_class)
    rf.render! controller_file: rf.filename, view_file: rf.view_filename,
               feature_file: rf.feature_filename
  end
end

__END__

@@ controller_file
# [Controller] <%= classname %>
#   (<%= filename %>)
# vim: foldlevel=1
# created at: <%= Time.now.strftime('%F') %>

# Web page controller for <%= classname %>
class <%= class_string %>
  get '/' do
    rsp :index
  end

  Route << self
end

@@ view_file
=h1 tt("<%= classname %>.title")

@@ feature_file
Feature: walk through pages for <%= classname %>
  Include the description here

  Scenario: show '/index' page
    Given I visit to "/index"
    Then I should see the text "Hello, world!"
