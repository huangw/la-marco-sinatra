# Assets文件管理

## 概要

- 管理（包括编译和最小化）`js/css`文件，同时管理logo，icon等静态图片
- 支持从git或http下载第三方`js/css`文件到本地
- AssetsHelper统一提供`js_tag`, `css_tag`和`img_tag`，根据三种不同的环境提供不同的文件地址：
    1. `:production`：等同于`RACK_ENV`的生产环境，能够使用单独Asset服务器
       （`img.vikkr.com, assets.vikkr.com`等）
    2. `:local_assets`：`RACK_ENV`还是`production`，但是使用本地图片和本地`css/js`
       的最小化文件。启动服务器时需制定参数`RACK_ENV=production LOCAL_ASSETS = true`。
    3. `:development`，等同所有非production环境，使用本地未最小化的css/js文件。
- css/js可以使用第三方CDN提供的地址，但在上述2.和3.的情况下，会使用下载备份到本地的文件，
  因此即使没有网络也可以完成本地测试。
- 通过ruby DSL写assets的设置（默认在`app/assets/mappings.rb`），可以支持更灵活的语法
 （取代以前的`definition.yml`，AssetsHelper使用的设置文件依然保存在`config/assets.yml`）
- 暂时不负责编译`coffee/sass`文件。应通过`sass -w`或其它命令行工具另行编译成`js/css`文件，
  并在`mappings.rb`里加载编译后的`js/css`文件地址

## 使用流程

### 图片管理

- 静态图片默认存放在`app/assets/img`下（可通过设置变量`img_dir`修改，但是不建议修改）：


    img_dir 'other/directory/for/img' # default is app/assets/img


- 文件可以保存于根目录，如`app/assets/img/logo.jpg`，也可建任意多层子目录如
  `app/assets/img/icon/group.jpg`。

为符合URL规范，注意不要用`_`命名文件或文件夹（可用`-`）。

- 指定服务器在不同的环境下如何从图片ID生成图片URL（最后的`/`可选）：

    img_url_prefix production: 'http://img.vikkr.com',
                   local: '/img'

对于任意图片，如`image_filename = icon/group/friends.png`，调用`img_tag`的方法为：

    = img_tag('icon/group/friends.png')

`:production`环境下使用`img_url_prefix.remote`，而。
`:local_assets`和`:development`使用`img_url_prefix.local`。

- `AssetsHelper.img_tag(image_filename)`中图片URL为：
  `<当前环境的img_url_prefix>/<image_filename>`。
  如`http://img.vikkr.com/icon/group/friends.png`（生产环境），
  `/img/icon/group/friends.png`（其它环境）。

- `ImageController`则会在`app/assets/img/icon/group/friends.png`
  中寻找图片文件并`sendfile`给用户。

- 执行`rake assets:map`，`rake assets:update`或者
  `rake assets:compile`会更新`config/assets.yml`，服务器（WebApplication）
  通过读取此文件获得 `AssetsSettings::EnvironmentSettings`的
  singleton instance，并在非production环境时，mount
  `AssetsMapper::ImageController`到`/img`（即`img_url_prefix.local`的设置位置）。

AssetHelper并不管理具体文件的尺寸，因此需要时应手动指定尺寸：


    = img_tag('icon/group/friends.png', width: 230)


非生产环境下可以通过`localhost:8080/img/index`列出所有现有静态图片的id和尺寸。

### 第三方Git库的下载管理

    pull :repoid, git: 'http://some.url.com/git/repository.git'
    pull :jquery2, github: 'jquery/jquery' # github可直接指定repository名称
    pull :la-marco, 7lime: 'vikkr/la-marco' # gitlab.7lime.com的库也可缩写


会将`https://github.com/jquery/jquery`下载到`~/.assets_cache/jquery2`
（或任意指定的`pull_dir`）。

注意用symbol指定下载文件夹名称（否则会被当做实际目录名而非`~/.aasets_cache`下的目录名）。

以后就可通过vendor命令，从vendor库里拷贝文件了：

    produce('some.js') { vendor 'lib/some/file/vieee.jp', from: :jquery2 }

这个文件默认会被拷贝到`app/assets/vendor/jquery2/vieee.jp`
(`vendor_dir` + repository名 + 文件basename)。

### CSS和JS文件管理

#### 虚拟文件和最小化

CSS和JS管理的核心是虚拟文件（对应一个`AssetMapper::TargetFile`），如`application.js`,
`editor.css`，每一个虚拟文件都是有一个或多个文件（`AssetMapper::SourceFile`）组成的。
在`mappings.rb`文件里，通过`produce`命令设置：


    produce 'application.js' do
      cloud '//code.jquery.com/jquery-2.1.3.min.js'
        # 文件会被拷贝到`app/assets/cloud/code.jquery.com/jquery-2.1.3.min.js`

      vendor 'lib/min/sometool.min.js', from: :bootstrap
        # `~/.assets_cache/bootstrap`需已经存在
        # 文件默认会被拷贝到`app/assets/vendor/bootstrap/sometool.min.js`

      file 'js/article-editor.js' # 使用 `app/assets/js/article-editor.js`
                                  # `app/assets`可通过`assets_dir`命令修改，
                                  # 所有文件地址均相对于此地址指定
      file 'js/subdir/myown.js' # 使用`app/assets/js/subdir/myown.js`，
    end

    produce 'editor.css', minimize_to: 'public/assets/css' do
      ...
    end

**vendor** 是copy过来用、并会被压缩到我们自己的最小化`js/css`中的文件
（比如application.versionid.js）。而 **cloud** 在生产环境中则是直接远程调用的，
但是也会下载一个本地备份用于`:development`和`:local_assets`时的测试。

**file** 则是普通的我们自己开发的`js/css`文件。它们可能从`coffee/sass/less`等编译而来，
这里应该指定生成的`js/css`文件。

`rake assets:compile`会针对每一个produce对象在`app/assets/min/`
（此为`min_dir`变量默认所指定的目录）下生成最小化的js和css版本，并有含短缩时间戳的版本号
（如`application.dfwee.js`，`dfwee`即为版本号，每秒钟对应一个，可从中复原时间戳）。

也可另行定义min文件的存储地址：

    produce 'editor.css', minimize_to: 'public/assets/css' do
      ...
    end

`cloud`指定的文件不会被压缩。

注意`cloud`和`vendor/file`混在时，无论其指定顺序如何，`cloud`文件永远会在缩小版文件前被调用。

`vendor/file`文件则会按照定义的顺序调用或压缩在一起。

#### URL地址和文件获取

与图片一样，生产环境下压缩后的js/css文件应该保存于`//assets.vikkr.com`之类的子域名
（可能在OSS上）。需要指定为：

    assets_url_prefix production: 'http://assets.vikkr.com'
                      local: '/assets'


原理与`image_url_prefix`一样。

对任一个produce的filename（如`js_tag('application.js')`），`js_tag`和`css_tag`
会按设置顺序输出一个或多个`<link>/<script>`。

- `:production`环境下，cloud文件单独采用指定的地址，其他本地文件最小化为带版本号的一个文件，
  以`<assets_url_prefix.production>/application.xdewrwer.js`形式提供。
- `:local_assets`环境下，cloud文件为本地备份文件地址，其他本地文件最小化为带版本号的一个文件，
  以`<assets_url_prefix.local>/application.xdewrwer.js`形式提供。
- `:development`环境下，单独返回使用每一个组成文件，均为本地文件的URL地址

## 技术实现

### AssetSettings

`lib/asset_settings.rb`文件负责解析并更新`config/assets.yml`文件。

后者将`:production/:development/:local_assets`三个文件分别保存，`WebController`等
controller在runtime根据当前环境获取其中一个（singleton对象）。

`assets.yml`里定义一个root地址（相当于`APP_ROOT`），对于图片只保存`img_dir`
（相对于`APP_ROOT`）和`img_url_prefix`。对于css/js文件，则保存`files`Hash，
为`虚拟文件 => 原始文件数组`的列表。
原始文件数组的元素均为经过了`aasets_url_prefix`转换后的URL地址
（注意：本地地址均是相对于`root`的）。

### Assets Helper

提供`img_tag`, `css_tag`和`js_tag`，根据`config/assets.yml`（`AssetsSettings`）的设置，
在不同的环境（`:production/:local_assets/:development`）输出不同的资源列表。

### Assets Controller

因为资产文件不再放置于`public`文件夹下，需要根据需要（一般由WebApplication）
在Route里加载`ImageControler`和`AssetController`以提供这些文件（具体的mount地址也从
`AssetsConfig`获取）。

### Assets Mapper

此类仅在开发环境下通过`rake assets:*`使用。负责解析`app/assets/mappings.rb`，
根据需要下载、复制、编译或最小化压缩文件，更新YAML设置文件。
