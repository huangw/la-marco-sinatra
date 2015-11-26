require 'devtools/file_generator'

# Helper for rake to generate source files
class FileGenerator
  # API controller file generator
  class ControllerFile < RubyFile
    def initialize(name, su = nil)
      @filename = name.to_s.underscore
                      .sub(/\Aapp\/pages\//, '')
                      .sub(/\.rb\Z/, '')
      filepath = "#{@filename}_page" unless @filename.match((/_(api|page|controller)\Z/))
      su ||= 'WebController'
      super "app/pages/#{filepath}", su
    end

    def file_path
      Route.default_path(class_name)
    end

    def url_path
      Route.default_url(class_name)
    end

    def feature_filename
      File.join('features', "#{file_path}.feature")
    end

    def view_filename
      File.join('app', 'views', file_path, 'index.slim')
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
# [Controller] <%= class_name %>
#   (<%= filename %>)
# vim: foldlevel=1
# created at: <%= Time.now.strftime('%F') %>

# Web page controller for path to '<%= url_path %>'
class <%= class_string %>
  get '/' do
    rsp :index
  end

  Route << self
end

@@ view_file
=h2 tt("title")

@@ feature_file
Feature: walk through pages for '<%= url_path %>' (<%= class_name %>)
  Include the description here

  Scenario: show '<%= url_path %>/index' page
    Given I visit to "<%= url_path %>/index"
    Then I should see the text "<%= class_name %>"
