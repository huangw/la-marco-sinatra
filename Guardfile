# vi: ft=ruby
# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rubocop, all_on_start: false, cli: ['--format', 'clang', 'app/**/*.rb'] do
  watch(%r{^app/(.+)\.rb$})
end

guard :rspec, cmd: 'bundle exec rspec --color -f d' do
  watch('spec/spec_helper.rb')  { 'spec' }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/support/(.+)\.rb$}) { 'spec' }

  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^config/(.+)\.rb$}) { |m| "spec/config/#{m[1]}_spec.rb" }
end

guard :rake, task: 'server' do
  watch(%r{^app/.+\.(rb)$})
  watch(%r{^lib/.+\.(rb)$})
  watch(%r{^config/.+\.(rb)$})
  watch('config.ru')
end

guard :cucumber, run_on_start: false do
  watch(%r{^features/.+\.feature$})
  watch(%r{^app/pages/.+\.feature$}) { 'features' }
  watch(%r{^features/support/.+$}) { 'features' }
end
