desc 'Create or Update ctags file'
task :ctags do
  sh 'ctags -R --exclude=*.js .'
end
