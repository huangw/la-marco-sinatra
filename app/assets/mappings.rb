pull :typo, github: 'sofish/typo.css', update: false
pull :marco, vikkr: 'vikkr/la-marco.git', branch: 'develop', update: false

produce 'application.css' do
  cloud 'http://cdn.amazeui.org/amazeui/2.1.0/css/amazeui.min.css',
        update: false
  file 'css/standard.css'
  file 'css/edit.css'
  vendor 'typo.css', from: :typo
end

produce 'application.js' do
  file 'js/base.js'
  file 'js/extra.js'
end
