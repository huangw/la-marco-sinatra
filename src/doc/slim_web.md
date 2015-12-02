# Slim工具和Web控制器

## SlimHelper

一个Controller类（如`Admin::Analytics::PageViewPage`）的template模板文件保存于
`Route.default_path(Admin::Analytics::PageViewPage)`
（上面的例子为admin/analytics/page-view）。

注意，因为Controller类可能被mount到`default_path`之外的URL，所以保存模板文件的位置，
与URL的结构并不一致。具体的，`Route[Admin::Analytics::PageViewPage]`
会返回类实际mount的URL地址，而`Route.default_path(Admin::Analytics::PageViewPage)`
的返回值则是模板文件的存储地址。

`rsp :模板名`会将上述模板文件目录下的`模板名.slim`文件用于render。
注意模板名必须以`symbol`格式指定（注意现在的rsp函数只有一个hash参数）。

`SlimHelper`会尝试从`path_info`算出默认模板，如果是静态不含`:param`的路径，
则可以直接调用`rsp`函数，不指定模板文件ID：

    class UserPage
      get('/message') # 模板为：app/views/users/message.slim
      get('/settings/nickname')
        # 模板为：app/views/users/settings/nickname.slim
      get(/) # app/views/users/index.slim，'/'会自动map到:index
    end

与`rsp`相对应，`rsp!`render后直接halt当前进程（即以前的`hsp`）。

新的`SlimHelper`不再有`common_rsp`，应直接`@对象变量`传递信息。依然有`partial :form`（使用`_form.slim`文件作为template），但是不再有`partial_block`函数
（后者应该使用模型自身的`HtmlPresenter`机制）。

`partial`功能应该用于template内部，比如：`partial :form`会调用同一文件夹下的`_form.slim`。

## i18n Helper

有两种方式在slim模块中实现i18n，两种可以并用。第一种方式是，针对不同locale分别做一个模板，
比如`index.en.yml`和`index.ja.yaml`。模板的locale必须包含在`supported_locales`中，
默认是`en, ja, zh`（统一使用缩略写法，不再用'zh-CN'的方式了）。然后render时，指定：

    rsp :index, locales: [:en, :ja]

注意这里的`locales`表示的是“所有我提供了模板的locales”。这个例子里没有`zh`模板存在，
对指定locale为`zh`的用户，SlimHelper会使用默认的模板（:en）render。
因此，`:en`模板是必须存在的（这一点未来可能有所改善）。

另一种方法是使用同一个模板，但是用`tt(:some_key)`将`:some_key`翻译为不同语言。
`tt`由`I18nHelper`提供，会自动的按照当前页面寻找正确的scope。
比如，`app/views/some/template.slim`文件里的`:some_key`，应该在
`i18n/views/some/en.yml`（或`ja.yml`, `zh.yml`）里定义为`some.template.some_key`。

在slim文件内增加新的key到`tt`之后（注意必须用`:xxx`，也就是symbol形式），然后执行
`rake i18n:uv`，后者会自动在yaml文件里添加新的key，并通过google translate预设一个翻译。
以后则可以通过

    $ rake i18n:iye

启动翻译服务，通过浏览器人力对照翻译。

spec:lib/helpers/i18n_helper

### 面包屑

因为`Route`加载时可以指定任意的mount point，比如`User::RootPage => '/'`，
系统无法从任意位置完全自动的生成面包屑（包括所有上级目录的连接和i18n的页面title）。
但是主要遵循几个简单原则，则手动生成面包屑也非常轻松：

首先，所有直接链接到目录的页面，均应命名为`index`。
比如`/user/`对应`user/index`。它的i18n标题的翻译键则应该为：`user.index.title`。

比如`User::AccountPage`里的`get '/message_center'`，如果加载在了默认路径
（`user/accounts/message_center`），则它的面包屑的各段的翻译key应该为
`[:user.index.title, :user.accounts.index.title, :user.accounts.message_center.title]`。

理论上只要上述`index`页面对应的slim模板存在，则`rake i18n:uv`也应该生成了这些key，
在render面包屑时可以使用。

注意：不要字模板文件中使用`title`关键字，如`/title/some.slim`或是`/some/title.slim`。

## Form Helper

是一个简单的输出与表单相关的HTML代码的DSL方法集。具体用法参照其`rspec`测试文件。

spec:lib/helpers/form_helper

## Table Helper

TODO: 与Angular等联动

## 自动生成页面

`rake gen:page`会自动生成三个文件，比如执行`rake gen:page name=user_setting`
（注意没有`s`），会生成以`WebController`为基类的`app/pages/user_settings_page.rb`，
相应的slim模板`app/views/user_settings/index.slim`，
和`features/user_settings.feature`。

然后执行`rake i18n:uv`会添加`index.slim`中的i18n用的关键字，之后在浏览器浏览
`http://localhost:8080/user/settings`应该就可以看到希望的结果了。
