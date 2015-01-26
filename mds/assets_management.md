# Asset (js/css) Pipeline Management

## 概要

- 管理（包括编译和最小化）`js/css`文件，同时管理logo，icon等静态图片
- 支持从git或http下载第三方`js/css`到本地；支持oss管理和上传文件
- Controller类在使用静态图片、js和css时，应使用AssetsHelper统一提供`js_tag`, `css_tag`和`img_tag`，根据三种不同的环境提供不同的文件地址：
    1. `:production`：等同于`RACK_ENV`的生产环境，使用单独Asset服务器（`img.vikkr.com, assets.vikkr.com`等）时的情况
    2. `:local_assets`：RACK_ENV还是`production`，但是使用本地的图片和`css/js`文件（缩小版）。启动服务器时需要制定参数`LOCAL_ASSETS = true`。
    3. `:development`，等同所有非production环境，使用本地未编译的css/js文件。

    2.和3.两种情况下，包括`:production`环境下使用的第三方云端js的也会下载到本地。因此即使没有网络也可以完成本地测试。

- 取代以前的`definition.yml`，通过ruby DSL写assets的设置（默认在`app/assets/mappings.rb`），可以支持更灵活的语法。AssetsHelper使用的设置文件依然保存在`config/assets.yml`

## 基本的工作流程

### 图片管理

- 静态图片放在`app/assets/img`下，可以直接存放为`app/assets/img/logo.jpg`，或再建一层文件夹如`app/assets/img/icon/group.jpg`(注意仅支持一层文件夹)。

- 为符合URL规范，注意不要用`_`命名文件或文件夹（可用`-`）。上述例子中的`logo.jpg`和`icon/group.jpg`就是图片ID

- 如果需要保存在`app/assets/img`之外，可以在`app/assets/mapping.rb`中设置：

~~~~~~~~~~~~~~~~~~~~~ruby
img_dir 'other/directory/for/img'
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

甚至不同环境采用不同文件存储位置：

~~~~~~~~~~~~~~~~~~~~~ruby
img_dir production: 'other/directory/for/img',
        development: 'yet/an/other/directory'
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

（不建议这样做）。

- 指定服务器在不同的环境下如何从图片ID生成图片URL（最后的`/`可选）：

~~~~~~~~~~~~~~~~~~~~~ruby
img_prefix production: 'http://img.vikkr.com',
           development: '/img' # '/img'是默认值，可以不写
                               # 图片不编译压缩，因此:local_assets和
                               # :development共享相同的URL路径
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

上述设置下，生产环境调用`img_tag('icon/avatar.jpg')`获得`http://img.vikkr.com/icon/avatar.jpg`，而开发环境和local-assets下为`/img/icon/avatar.jpg`。

- 执行`rake assets:map`，`rake assets:update`或者`rake assets:compile`会更新`config/assets.yml`，服务器（WebApplication）通过读取此文件，并在非production环境时，mount`AssetsMapper::ImageController`到`/img`（即`img_prefix`的设置）。

- WebApplication同时嵌入`assets_helper`，后者提供`css_tag/js_tag/img_tag`方法。需要使用静态图片时，可在模板中使用：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ruby
= img_tag('icon/avatar.jpg')
= img_tag('icon/avatar.jpg', width: 230)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

AssetHelper并不管理具体文件的尺寸，因此需要时应手动指定尺寸。非生产环境下可以通过`localhost:8080/img/index`列出所有现有静态图片的id和尺寸。

### CSS和JS管理

CSS和JS管理的核心是虚拟的文件，如`application.js`, `editor.css`，每一个虚拟文件都是有一个或多个文件组成的。在`mappings.rb`文件里，通过`produce`命令设置：

~~~~~~~~~~~~~~~~~~~ruby
pull :bootstrap, github: 'awb/bootstrap' # 先下载到本地`~/.assets_cache/bootstrap`

produce 'application.js' do # 创建一个需要编译压缩的js（或css）文件
  cloud '//code.jquery.com/jquery-2.1.3.min.js'
    # 文件会被拷贝到`app/assets/cloud/js/code_jquery_com/jquery-2.1.3.min.js`

  vendor from: :bootstrap, file: 'lib/min/sometool.min.js'
         # `~/.assets_cache/bootstrap`需已经存在
         # 文件会被拷贝到`app/assets/vendor/js/bootstrap/sometool.min.js`

  use 'article-editor.js' # 使用 `app/assets/js/article-editor.js`
  use 'subdir/myown.js' # 使用`app/assets/js/subdir/myown.js`，所有文件ID的指定
                        # 都相对于`app/assets`

  use 'myothertool.js', from: 'coffee/myothertool.coffee'
       # `app/assets/coffee/myothertool.coffee`会被用于编译
       # `app/assets/js/myothertool.js`
       # 如果不需要`rake assets:update`编译js文件，当然也可以
       # 忽略`from:`部分，直接将`myothertool.js`文件当做普通js文件

  use 'coffee/myothertool.coffee'
       # 遇上一行效果一样，如果文件都在默认位置，可直接指定coffee文件
end

produce 'editor.css' do
  ...
end
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**vendor**是copy过来用、并会被压缩到我们自己的js/css中的文件（比如application.versionid.js）。而**cloud**在生产环境中则是直接远程调用的，但是也会下载一个本地版用于`:local_assets`时的测试（这样即使不能联网，本地app依然可通过指定`LOCAL_ASSETS=true RACK_ENV=production`启动服务器以测试`production`环境下的运行情况）。

`rake assets:compile`会针对每一个produce对象在`app/assets/min/(js|css)`下生成最小化的js和css版本。
文件夹可以通过`min_dir`变量修改。但是`cloud`指定的文件不会被压缩。

与图片一样，生产环境下压缩后的js/css文件应该保存于`//assets.vikkr.com`之类的子域名（可能在OSS上）。需要指定为：

~~~~~~~~~~~~~~ruby
assets_prefix production: 'http://assets.vikkr.com',  # http://assets.vikkr.com/js/...
              development: '/assets'     # 本地URL则变为：/assets/js/...，或/assets/min/js/...

~~~~~~~~~~~~~~~~~~~~~

另外几个可以修改但是不建议修改的变量为（全部为`app/assets`的子目录）：

~~~~~~~~~~~~~~~ruby
min_dir 'min'       # 此为默认值，不需要修改
vendor_dir 'vendor' # 从git等下载、拷贝来的内容存放的位置
cloud_dir 'cloud'   # 从云端下载的用于纯本地测试的缓存文件的存放位置
~~~~~~~~~~~~~~~~~~~~~~

对任一个produce的文件ID（如`application.js`），`js_tag`和`css_tag`会按设置顺序输出一个或多个`<link>/<script>`。

- `:production`环境下，为cloud指定的地址，和其他本地文件最小化之后的带版本号的文件
- `:local_assets`环境下，cloud文件为本地cache文件，其它为本地压缩的文件`/assets/min/js/mytooo.xzxs.js`
- `:development`环境下，单独使用每一个组成文件

### 上传下载管理

~~~~~~~~~~~~~~~~~~~~~~ruby
pull :repoid, git: 'http://some.url.com/git/repository.git'
pull :jquery2, github: 'jquery/jquery' # github可直接指定repository名称
pull :la-marco, 7lime: 'vikkr/la-marco' # gitlab.7lime.com的库也可缩写
~~~~~~~~~~~~~~~~~~~~~~~~~~

会将`https://github.com/jquery/jquery`下载到`~/.assets_cache/jquery2`。

注意用symbol指定下载文件夹名称（否则会被当做实际目录名而非`~/.aasets_cache`下的目录名）。

以后就可在vendor命令里拷贝文件了：

~~~~~~~~~~~~~~~~~~~~~~ruby
produce('some.js') { vendor :jquery2, 'lib/some/file/vieee.jp' }
~~~~~~~~~~~~~~~~~~~~~~~~~~

这个文件会被拷贝到`app/assets/vendor/jquery2/vieee.jp`，除非另行指定。

## 程序实现

资产文件管理由下列几个组成部分实现：

### Assets Configuration

每次执行`rake assets::*`会根据`app/assets/mappings.rb`的设置更新`config/assets.yml`文件。设置内容主要为两部分：全局设置变量（各种文件的存储路径等）和需要produce的assets的列表。这个文件在启动时调入`config/initializers/assets_settings.rb`（加载到全局的`AssetsSettings`）。

### Assets Helper

提供`img_tag`, `css_tag`和`js_tag`，根据`config/assets.yml`（`AssetsSettings`）的设置，在不同的环境（`:production/:local_assets/:development`）输出不同的资源列表。

### Assets Controller

因为资产文件不再放置于`public`文件夹下，需要根据需要（一般由WebApplication）在Route里加载`ImageControler`和`AssetController`以提供这些文件（具体的mount地址也从`AssetsConfig`获取）。

### Assets Mapper

负责解析`app/assets/mappings.rb`，根据需要下载、复制、编译或最小化压缩文件，更新
