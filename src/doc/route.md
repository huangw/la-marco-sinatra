# Route机制和Puma进程管理

## Route管理

Route定义一个全局（通过Route类的一个eigenclass变量）的路由表，记录controller类（`UserPage`等，遵循rack标准）到URL path（mounting point，如`/users`）的映射关系。

`Route.table`返回`类 => 路径`，`Route.all`则返回`路径 => 类`格式的Hash。

注意1.9之后的Ruby Hash是有序的，all的顺序与table相反。

一般来说，我们通过`Route.mount AppClass, '/path'`或
`Route << AppClass`将controller加载到`Route.table`，当path没有指定时，Route会自动转换`NameSpace::ClassNamePage`为`name/space/class/names`的形式（末尾的`Controller/Page/API`会被删除，然后复数化）。

Controller类使用默认route路径时，可以在定义时直接加载：

    class UserPage < WebApplication
      get('/') { ... }

      Route << self
    end


默认路径由`default_route`函数根据类名（`UserPage`）计算出。

也可同时定义特定path：

    class UserPage < WebApplication
      get('/') { ... }

      Route.mount(self, '/user')
    end

或在任意地方、根据特定条件加载：

    Route.mount(LogViewApp, '/logs') if RACK_ENV == 'development'

spec:lib/route

## 获取特定path

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
        # redirect to /p/title-tid
        redirect Route.to(post.url)
      end
    end

## 启动时加载Controller

程序启动时`config/boot.rb`会在`config/routes.rb`文件存在时调用它，后者会顺序加载所有`app/helpers`和`app/pages`下面的ruby文件。旧版的`app/lib/*`文件移动到`lib`目录下，需要使用时手动加载（一般来说应该已经被base controller加载了）。

最后`config/routes.rb`会“从浅到深”的加载`app/pages`下的所有文件。`Route.all`会以相反的顺序将其map到`control.ru`。
这样大致可以保证`/`之类更“一般”的route会出现在寻址表的最后。
`config.ru`（标准的rack程序入口）里，会顺序调用并map所有的`Route.all`到一个大的`Rack::Builder` application。

spec:config/initializers/routes

注意`web exceptions`设置文件中定义了特定Ruby异常对应的HTTP错误代码，会被`routes`初始化脚本调用：

spec:config/initializers/web_exceptions

## Puma进程管理

重新使用`foreman`，用于开发和测试时启动各种服务器包括`puma`。启动`puma`时会调取`config/puma.rb`文件，监听8080端口并记录`pid`文件到本地`tmp`文件夹下，可通过`rake s`（`rake puma`的别名）快速重启。

注意`puma.rb`设置文件屏蔽了`access log`，必要时可以打开（屏蔽掉`quiet`一行）。

spec:config/puma

注意`app/pages/simplest_page`定义了一个`get`的`hello world`页面，启动puma后可以通过`http://localhost:8080/simple`确认是否能正常显示。

spec:app/pages/simplest_page

另外，`Guardfile`通过`guard-rake`插件动态监听本地文件的修改。建议在两个不同的terminal窗口分别启动`forman start`和`bundle exec guard`。则任何时候修改`app/pages/...`下的文件时`guad`会自动重启`puma`，不需要手动执行`rake s`了。
