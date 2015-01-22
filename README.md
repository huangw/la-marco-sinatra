# La-Marco-Sinatra: Sinatra Based Web Framework

注意：`sinatra`如果出现“undefined method `join` for #<String> ...”错误，参照`doc/monkey_patch.html`文件。

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

`Guardfile`里添加了监听`app/`下所有ruby文件变化并重启puma服务的功能。因此只要执行`bundle exec guard`（启动`rake s`后因为terminal被puma占据，因此只能另开terminal窗口启动guard）。Guard并不尝试启动`puma`，只负责重启。这是因为在Guard进程中无法植入debug console的原因。

在任意的程序代码中插入`binding.pry`，如：

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

### Route机制

`config/boot.rb`会在`config/routes.rb`文件存在时调用它，后者会加载所有`app/helpers`和`app/pages`下面的ruby文件。`app/lib/helper`和`app/lib`rack移动到`lib`目录下，需要使用时手动加载（一般来说已经被base controller加载了）。`app/base`目录取消，base controllers应该直接放在`app/pages`文件夹下，`config/routes.rb`会“从浅到深”的加载`app/pages`下的所有文件。

### Cucumber测试

