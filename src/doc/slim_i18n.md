# Slim和i18n工具

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
      get(/) { rsp } # app/views/users/index.slim，'/'会自动map到:index
    end

与`rsp`相对应，`rsp!`render后直接halt当前进程（即以前的`hsp`）。

新的`SlimHelper`不再有`common_rsp`，应直接`@对象变量`传递信息。依然有`partial :form`（使用`_form.slim`文件作为template），但是不再有`partial_block`函数
（后者应该使用`HtmlPresenter`机制）。

`partial`功能应该用于template内部，比如：`partial :form`会调用同一文件夹下的`_form.slim`。
