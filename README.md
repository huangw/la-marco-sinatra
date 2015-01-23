# La-Marco-Sinatra: Sinatra Based Web Framework

> 注意：`sinatra`如果出现“undefined method `join` for #<String> ...”错误，参照`doc/monkey_patch.html`文件。

## 概述

- `config.ru`实现rack标准，通过`puma`启动服务，非生产环境加载`pry-byebug`测试
- `Route`机制，独立app（如bluemoon）可无缝加载或移除
- Cucumber测试
- 基于`Route`的path helper，实现对面包屑的程序化管理
- slim helper, form和table helper
- 基于stackupper的asset helper和compiler
- I18n机制，包括JS/Ruby同步
- API helpers, API测试和文档helper

Center Logger和Email需要数据库支持，放到单独的程序中实现。

## 详细

### Puma管理和pry-byebug测试

不再使用`foreman`，直接通过`rake s`（`rake server`）启动puma服务，PID文件保存在本地`tmp/puma.pid`，因此`repuma`命令不再起作用。需重启服务器时再次执行`rake s`即可。

更细腻的控制可以通过`rake puma:start`, `rake puma:stop`和`rake puma:restart`实现。

`Guardfile`里添加了监听puma的功能。如果puma服务尚没有启动，则`bundle exec guard`也会在`guard`的控制台启动puma。如果puma已经启动，则`guard`会在`app/lib/config`文件夹下所有ruby文件发生变化时重启puma服务。

因为`guard`会重定向输入输出，在`guard`控制台下无法使用`pry`进行debug。需要使用`pry`时，应在单独的terminal窗口启动puma，再在另外的窗口启动`guard`。

单独窗口启动puma时，在程序代码中插入`binding.pry`，如：

```ruby
get('/some/route') do
  user = User.find(...)
  binding.pry

  ...
end
```

则`rake s`启动的puma进程会在此处停止并启动pry控制台，在这里可以

    pry> ap user

来确认变量，或插入并执行任意代码。

注意：`rake server`通过`tmp/puma.pid`文件的存在与否判断puma是否在运行。如果puma因某种原因未能在退出时删除此文件导致puma无法启动，可手动删除。

### Route机制

参照`doc/route.html`

`config/boot.rb`会在`config/routes.rb`文件存在时调用它，后者会顺序加载所有`app/helpers`和`app/pages`下面的ruby文件。旧版的`app/lib/*`文件移动到`lib`目录下，需要使用时手动加载（一般来说应该已经被base controller加载了）。

`app/base`目录取消，base controllers应该直接放在`app/pages`文件夹下，`config/routes.rb`会“从浅到深”的加载`app/pages`下的所有文件。

### Cucumber测试

Cucumber支持通过`poltergeist`或`chrome`两种driver测试，默认是`poltergeist`。两者均直接连接puma在本地监听的8080端口进行测试。因此cucumber必须在puma启动后方可执行。

`chrome`和`poltergeist`需要分别单独安装`chrome-web-driver`和`phantomjs`之后才可以使用。

需使用`chrome`测试时，可指定`DRIVER=chrome rake features`，也可以使用短缩版的命令`rake cc`（Cucumber with Chrome）。

`rake accept`则会将测试结果以html报告的形式保存到`doc/cucumber.html`。

在确保puma已经启动的情况下，可通过`rake puma:restart && rake f`来先重启服务器在执行cucumber。注意如果puma没有另外启动，则`rake s`会占据整个进程，`rake f`无法获得启动机会。因此**不要使用**`rake s && rake f`。

Guard设置为检测本地文件变化并重启服务器，同时监听`features/*.feature`或`app/pages/*.rb`文件变化并执行cucumber。当然同样需要puma在另外的窗口运行时才有意义。

### Path管理和Slim模板

#### 获取特定path

`to`（`url`的同名函数）是sinatra提供的获取同一controller内其它页面URL的方法，比如

    class UserPage < WebApplication
      get('/settings') { ... }
      get('/') { rediret to('settings') } # redirect to the url of above

      Route << self # => mount to '/users/'
    end

`Route.to`方法（可接受多个参数）则是一种“全局”跳转：

    class BookPage < WebApplication
      get('/') do
        # redirect to /users/xxxuser_tidxxx/settings
        redirect Route.to(UserPage, current_user.tid, 'settings')
      end
    end

#### SlimHelper

一个Controller类（如`Admin::Analytics::PageViewPage`）的template模板文件保存于`Route.default_path(Admin::Analytics::PageViewPage)`（上面的例子为admin/analytics/page-view）。

注意，因为Controller类可能被mount到`default_path`之外的URL，所以保存模板文件的位置，与URL的结构并不一致。具体的，`Route[Admin::Analytics::PageViewPage]`会返回类实际mount的URL地址，而`Route.default_path(Admin::Analytics::PageViewPage)`的返回值则是模板文件的存储地址。

`rsp :模板名`会将上述模板文件目录下的`模板名.slim`文件用于render。注意模板名必须以`symbol`格式指定（注意现在的rsp函数只有一个hash参数）。

`SlimHelper`会尝试从`path_info`算出默认模板，如果是静态不含`:param`的路径，则可以直接调用`rsp`函数，不指定模板文件ID：

    class UserPage
      get('/message') # 模板为：app/views/users/message.slim
      get('/settings/nickname')
        # 模板为：app/views/users/settings/nickname.slim
      get(/) { rsp } # app/views/users/index.slim，'/'会自动map到:index
    end

与`rsp`相对应，`rsp!`render后直接halt当前进程（即以前的`hsp`）。

新的`SlimHelper`不再有`common_rsp`，应直接`@对象变量`传递信息。依然有`partial :form`（使用`_form.slim`文件作为template），但是不再有`partial_block`函数（后者应该使用`HtmlPresenter`机制）。

`partial`功能应该用于template内部，比如：`partial :form`会调用同一文件夹下的`_form.slim`。

### 模板I18n

有两种方式在slim模块中实现i18n，两种可以并用。第一种方式是，针对不同locale分别做一个模板，比如`index.en.yml`和`index.ja.yaml`。模板的locale必须包含在`supported_locales`中，默认是`en, ja, zh`（统一使用缩略写法，不再用'zh-CN'的方式了）。然后render时，指定：

    rsp :index, locales: [:en, :ja]

注意这里的`locales`表示的是“所有我提供了模板的locales”。即使这个例子里没有`zh`模板存在，对指定locale为`zh`的用户，SlimHelper会使用默认的模板（:en）render。因此，`:en`模板是必须存在的（这一点未来可能有所改善）。

另一种方法是使用同一个模板，但是用`tt(:some_key)`将`:some_key`翻译为不同语言。`tt`由`I18nHelper`提供，会自动的按照当前页面寻找正确的scope。比如，`app/views/some/template.slim`文件里的`:some_key`，应该在`i18n/views/some/en.yml`（或`ja.yml`, `zh.yml`）里定义为`some.template.some_key`。

在slim文件内增加新的key到`tt`之后（注意必须用`:xxx`，也就是symbol形式），然后执行`rake i18n:uv`，后者会自动在yaml文件里添加新的key，并通过google translate预设一个翻译。以后则可以通过

    $ rake i18n:iye

启动翻译服务，通过浏览器人力对照翻译。

### 面包屑

`user/accounts/message_center`页面，假设在`User::AccountPage`里的`get '/message_center'`里定义，则它的面包屑路径的未翻译的key应该为`[:user.index.title, :accounts.index.title, :message_center.title]`。需要加入到面包屑的所有的目录，必须在`i18n`中有一个对应`index.title`的key才能自动翻译。

理论上`rake i18n:uv`也应该生成了这些key，在render面包屑时可以使用。注意：千万不要用`/title/some.slim`或是`/some/title.slim`命名模板文件。
