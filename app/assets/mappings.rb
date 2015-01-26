pull :bootstrap, github: 'twbs/bootstrap', branch: 'v3.3.0', update: false
pull :marco, vikkr: 'vikkr/la-marco.git', branch: 'develop', update: false

produce 'application.css' do
  vendor 'dist/css/bootstrap.css', from: :bootstrap
end
