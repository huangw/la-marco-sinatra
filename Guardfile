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

guard :shell do
  watch(%r{^app/.+\.(rb|feature)$}) do |m|
    if File.exist?('tmp/puma.pid')
      puts "puma running, restart"
      pid = File.read('tmp/puma.pid').chomp.to_i
      begin
        Process.getpgid( pid )
        sh "kill -USR2 #{pid}"
      rescue Errno::ESRCH
        "[PUMA] Pid file exists, but server not running, abort."
      end
      "[PUMA] `#{m[0]}` changed, restarting."
    else
      "[PUMA] `#{m[0]}` changed, but server not running, abort."
    end
  end
end

guard :cucumber do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})                      { 'features' }
end
