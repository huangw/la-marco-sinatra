pull :typo, github: 'sofish/typo.css', update: false
pull :marco, vikkr: 'vikkr/la-marco.git', branch: 'develop', update: false

produce 'application.css' do
  # vendor 'dist/css/bootstrap.css', from: :bootstrap
  cloud 'http://cdn.amazeui.org/amazeui/2.1.0/css/amazeui.min.css'
  file 'css/standard.css'
  file 'css/edit.css'
end

produce 'application.js' do
  file 'js/base.js'
  file 'js/extra.js'
end
