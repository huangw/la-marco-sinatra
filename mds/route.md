# Route机制

Route定义一个全局（通过Route类的一个eigenclass变量）的路由表，记录controller类（`UserPage`等，遵循rack标准）到URL path（mounting point，如`/users`）的映射关系。

`Route.table`返回`类 => 路径`，`Route.all`则返回`路径 => 类`格式的Hash。注意1.9之后的Ruby Hash是有序的，all的顺序与table相反。

一般来说，我们通过`Route.mount AppClass, '/path'`或`Route << AppClass`将controller加载到`Route.table`，当path没有指定时，Route会自动转换`NameSpace::ClassNamePage`为`name/space/class/names`的形式（末尾的`Controller/Page/API`会被删除）。

`config.ru`（标准的rack程序入口）里，会顺序调用并map所有的`Route.all`到一个大的Rack::Builder application。

如果所有的Controller Class都放在`app/pages`下，默认的`routes`文件会由浅至深调用其中全部的ruby文件。`Route.all`则会以相反的顺序将其map到`control.ru`。这样大致可以保证`/`之类更“一般”的route会出现在寻址表的最后。

Controller类使用默认route路径时，可以在定义时直接加载：

~~~~~~~~~~~~~~~~~~~~ruby
class UserPage < WebApplication
  get('/') { ... }

  Route << self
end
~~~~~~~~~~~~~~~~~~~~~~~

默认路径由`default_route`函数根据类名（`UserPage`）计算出。

也可同时定义特定path：

~~~~~~~~~~~~~~ruby
class UserPage < WebApplication
  get('/') { ... }

  Route.mount(self, '/user')
end
~~~~~~~~~~~~~~~~~~~~~~~

或在任意地方、根据特定条件加载：

~~~~~~~~~~~~~~~~~~~ruby
Route.mount(LogViewApp, '/logs') if RACK_ENV == 'development'
~~~~~~~~~~~~~~~~~~~~~~~

spec:lib/route
