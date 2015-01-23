# Asset (js/css) Pipeline Management

## Concept

- 通过`Stackupper`下载Jquery等第三方源码到本地（`app/assets/...`，一般在`app/assets/vendor`下）
- 在`app/assets`下用coffee或sass或普通的js，css书写文件
- 写`app/assets/mapper.rb`， 通过`rake assets:map`生成`config/assets.yml`文件
- `rake assets:compile`根据`app/assets/mapper.rb`定义最小化需本地提供的文件，并向外部云服务上传生成后的最小化文件
- `AssetHelper`提供`css_tag`和`js_tag`。开发环境下，`AssetController`（rack app）根据`mapper.rb`文件加载本地js和css，生产环境下根据定义的URL加载云端或外部host上的最小化文件

## Mapper定义

将下列内容保存为`app/assets/mapper.rb`

~~~~~~~~~~~~~~~~~~~ ruby
assets_directory 'app/assets'        # 'APP_ROOT'的相对路径

pull :jquery, git: 'https://github.com/jquery/jqueryj',

produce 'application.js' do
  copy :jquery, 'min/jsquery.js' => 'app/assets/'
end
~~~~~~~~~~~~~~~~~~~~~~~~
