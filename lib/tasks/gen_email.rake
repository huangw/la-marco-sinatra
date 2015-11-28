require 'devtools/file_generator'

namespace :gen do
  desc 'generating general email model and template files for NAME'
  task :email do
    name = ENV['NAME'] || ENV['name']
    fail 'need specify NAME=...' unless name
    name = name.sub(/\Aapp\/models\/emails\//, '')
    rf = FileGenerator::RubyFile.new("app/models/emails/#{name}")
    rf.render! model_file: rf.filename, spec_file: rf.spec_filename
    %w(en ja zh).each do |lang|
      rf.render! template_html: "app/views/emails/#{rf.filename}.#{lang}.html",
                 template_txt: "app/views/emails/#{rf.filename}.#{lang}.txt"
    end
  end
end

__END__

@@ model_file
# [Model] <%= class_name %>
# (<%= filename %>)
# vim: foldlevel=2
# created at: <%= Time.now.strftime('%F') %>

# mixin Emails namespace
module Emails
  # Email for <%= class_name %>
  class <%= class_string %> < Email
    def to_hash
    end
  end
end

@@ spec_file
require 'spec_helper'

describe Emails::<%= spec_name %> do
  subject(:<%= class_name.underscore %>) { <%= class_name %>.new }
end

@@ template_html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title><%= class_name %></title>
</head>
<body>
  <div style='color: red'>Email for <%= class_name %></div>
</body>
</html>

@@ template_txt
Subject: Email for <%= class_name %>
From: test@vikkr.com

TODO: Email for <%= class_name %>
