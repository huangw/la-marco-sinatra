pull :bootstrap, github: 'twbs/bootstrap', branch: 'v3.3.0', update: false
pull :marco, vikkr: 'vikkr/la-marco.git', branch: 'develop', update: false

produce 'application.css' do
  vendor 'dist/css/bootstrap.css', from: :bootstrap
  cloud 'http://cdn.amazeui.org/amazeui/2.1.0/css/amazeui.min.css'
end
