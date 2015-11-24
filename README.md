# La-Marco-Sinatra: Sinatra Based Web Framework

> 注意：`sinatra`如果出现“undefined method `join` for #<String> ...”错误，参照`doc/monkey_patch.html`)文件直接修改`sinatra`源码。

## Route机制和Puma进程管理

自行开发了`Route`机制，方便独立app（如bluemoon）的无缝加载或移除。同时开发了基于
`Route`的path helper，实现对面包屑的程序化管理。

详细参照参照[Route机制](route.html)文档

重新使用`foreman`，用于开发和测试时启动各种服务器包括`puma`。启动`puma`时会调取
`config/puma.rb`文件，监听8080端口并记录`pid`文件到本地`tmp`文件夹下，
可通过`rake s`（`rake puma`的别名）快速重启。

注意`puma.rb`设置文件屏蔽了`access log`，必要时可以打开（屏蔽掉`quiet`一行）。

spec:config/puma

注意`app/pages/simplest_page`定义了一个`get`的`hello world`页面，启动puma后可以通过
`http://localhost:8080/simple`确认是否能正常显示。

spec:app/pages/simplest_page

另外，`Guardfile`通过`guard-rake`插件动态监听本地文件的修改。建议在两个不同的terminal窗口
分别启动`forman start`和`bundle exec guard`。则任何时候修改`app/pages/...`下的文件时
`guad`会自动重启`puma`，不需要手动执行`rake s`了。

##
