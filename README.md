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

Cucumber测试支持通过`rack`, `chrome`和`poltergeist`之一，默认直接连接puma在本地监听的8080端口进行测试。因此必须在另外窗口启动puma后方可执行。`poltergeist`是默认driver。

`chrome`和`poltergeist`后两者需要分别单独安装`chrome-web-driver`和`phantomjs`之后才可以使用。`rack`不能解析js。

需使用`chrome`测试时，可指定`DRIVER=chrome rake features`，也可以使用短缩版的命令`rake cc`（Cucumber with Chrome）。

`rake accept`则会将测试结果以html报告的形式保存到`doc/cucumber.html`。

在确保puma已经启动的情况下，可通过`rake puma:restart && rake f`来先重启服务器在执行cucumber。注意如果puma没有另外启动，则`rake s`会占据整个进程，`rake f`无法获得启动机会。因此**不要使用**`rake s && rake f`。
