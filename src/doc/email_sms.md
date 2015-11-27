# 电子邮件和短信等的通知功能

## 发送电子邮件

### 邮件模块 EmailRender

邮件模块负责render不同语言、不同格式（txt或html）邮件body和header。

各个模型需要通过`#available_formats`, `#available_locales`指定可用模板的种类。
邮件发送时，`#delivery!`方法会根据当前的I18n环境和发送方法（`sender`）选择所采用的模板。

邮件模板默认为`liquid`格式，`subject`等以yaml格式写在`#available_formats.first`
模板的最前面几行（以空白与body部分区分开）。邮件header中还可以指定邮件发送的方式
（`mailgun`, `sendcloud` ... 等），因此不同种类的邮件可以通过不同的方法发送。

虽然任何类都可以`include EmailRender`，但建议将邮件全部统一为某个模型的子类，便于管理。

spec:lib/email_render

### 邮件发送服务 MailSender

发送服务是一种通用接口，可以接受各种header, html body, text body等参数并`#delivery!`。
不同的发送服务的子类实现通过mailgun，sendcloud等不同第三方服务实现邮件发送。
甚至不同邮件的可以选用不同的发送服务（如注册邮件采用送达率更高的服务）。

### 邮件开发和测试

使用`rake gen:email`可以自动创建邮件模型和相应的模板（两种格式和三种语言，
但可通过`ENV['locales']`和`ENV['formats']`指定）。

测试邮件是否发送成功应该通过验证数据库模型的方法进行。`la-marco-sinatra`还提供了一套
`email_controller`，可在开发环境下挂载到rack以便于确认render后的邮件效果。

## 短信 SMS

TODO: 选择国内合适的服务
