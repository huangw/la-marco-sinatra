# La-Marco-Sinatra: Sinatra Based Web Framework

> 注意：`sinatra`如果出现“undefined method `join` for #<String> ...”错误，参照`doc/monkey_patch.html`)文件直接修改`sinatra`源码。

## 在不同环境下启动Puma服务

自行开发了`Route`机制，方便独立app（如bluemoon）的无缝加载或移除。同时开发了基于
`Route`的path helper，实现对面包屑的程序化管理。

详细参照参照[Route机制](route.html)文档

重新使用`foreman`，用于开发和测试时启动各种服务器包括`puma`。启动`puma`时记录`pid`
文件到本地`tmp`文件夹下，可通过`rake s`（`rake server`的别名）快速重启。
