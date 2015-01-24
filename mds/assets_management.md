# Asset (js/css) Pipeline Management

## 概要

- `js/css`文件之外同时管理logo，icon等静态图片
- 从git或http下载第三方`js/css`到本地
- 文件保存在`app/assets/`，通过`app/assets/mappings.rb`管理（取代`definition.yml`）
- 通过`rake assets:update`生成`config/assets.yml`文件。`AssetsHelper`提供`css_tag/js_tag/img_tag`，基于`config/assets.yml`，根据环境（production?, local_only?）指向本地或云端
- `AssetsMapperPage`负责send本地文件（包括所有production版用于本地测试）
- oss管理和上传文件
- 不负责coffee和sass的编译（手动或通过guard由外部程序转换），但是负责通过`rake assets:compile`压缩（并做版本管理）

## 详细

### Mapper定义DSL

将下列内容保存为`app/assets/mapper.rb`

~~~~~~~~~~~~~~~~~~~ ruby
pull :jquery, git: 'https://github.com/jquery/jqueryj', branch: :develop

produce 'application.js' do
  vendor :jquery, 'min/jsquery.js' => 'public/assets/vendor/xxx.js'
  vendor 'http://....' => 'public/assets/vendor/xxx.js'
  cloud '//...' => 'public/assets/vendor/local.js'
    # download cloud js/css for development || local_only
    # use directly for production && !local_only
  copy 'my_handwritted.js', from: 'app/assets/...' # or use xxx.coffee
  upload_to 'assets.vikkr.com', ...
end
~~~~~~~~~~~~~~~~~~~~~~~~

**vendor**是copy过来用、并会被压缩到我们自己的js/css中的文件（比如application.versionid.js）。而**cloud**在生产环境中则是直接远程调用的，但是也会下载一个本地版用于`ENV[LOCAL_ONLY]=true`时的测试（这样即使不能联网，本地app依然可测试`production`环境下的运行情况）。

实际生产环境下，assets应该保存于单独sub domain（如`assets.vikka.com`）。

### Assets文件结构

以下是`app/assets/`的推荐结构：

    mappings.rb         # 定义文件
    coffee              # coffee script，但自己写的js同样可以放在这里
    sass                # sass和css
    img                 # 图片

public下文件，即使删除也可通过`rake assets:update`全部恢复：

    public/assets/js    # 将assets/coffee/下的文件编译、拷贝到这里
    public/assets/css   # 将assets/sass/下的文件编译、拷贝到这里
    public/assets/img   # 将assets/img/下的文件拷贝到这里
                        # 本地测试用production缩小版也在这里

    public/assets/vendor/js/
    public/assets/vendor/css/
                        # venders 下是第三方cs/jss文件，包括cloud版

