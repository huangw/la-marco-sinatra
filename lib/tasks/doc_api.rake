require 'rspec/core/rake_task'

namespace :spec do
  desc 'Run all (r)spec tests'
  RSpec::Core::RakeTask.new(:api) do |t|
    t.pattern = 'spec/pages/api/**/*_spec.rb'
    t.rspec_opts = '--format documentation --color'
  end
end

namespace :doc do
  desc 'Create API documentation'
  task :api do
    ENV['DOC'] = 'yes'
    ENV['DOC_SRC'] ||= 'src/api_doc'
    if File.directory?('spec/pages/api/')
      Rake::Task['spec:api'].invoke
      Dir["#{ENV['DOC_SRC']}/*.api.render.md"].each do |md|
        sh "aglio -t flatly -i #{md} -o #{md.sub(/\Amds\//, 'doc/')
           .sub(/\.render\.md\Z/, '.html')}"
      end
    end
  end
end
