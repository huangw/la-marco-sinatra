# Cucumber测试环境

Cucumber支持通过`chrome`和`poltergeist`启动测试，默认是`poltergeist`。
`chrome`和`poltergeist`需要分别单独安装`chrome-web-driver`和`phantomjs`。

使用`poltergeist`启动Cucumber时，可执行`rake features`或短缩版命令`rake f`。
`rake accept`会将测试结果以html报告的形式保存到`doc/cucumber.html`。

Cucumber直接连接puma在本地监听的8080端口进行测试。因此cucumber必须在puma启动后方可执行。

需使用`chrome`测试时，可指定`DRIVER=chrome rake features`，也可以使用短缩版的命令
`rake cc`（Cucumber with Chrome）。也可以使用`rake s && rake cc`的方式，
首先重启`puma`再行测试。

可设置每个页面加载之后的停顿时间，便于直接在`chrome`环境下测试UI：


TODO: 支持更多的web driver

spec:features/env.rb
