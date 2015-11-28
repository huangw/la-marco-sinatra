# 电子邮件和短信等的通知功能

## 发送电子邮件

### 邮件模块 EmailRender

邮件模块负责render不同语言、不同格式（txt或html）邮件body和header。

各个模型需要通过`#available_formats`, `#available_locales`指定可用模板的种类。
邮件发送时，`#deliver!`方法会根据当前的I18n环境和发送方法（`sender`）选择所采用的模板。

邮件模板默认为`liquid`格式，`subject`等以yaml格式写在`#available_formats.first`
模板的最前面几行（以空白与body部分区分开）。邮件header中还可以指定邮件发送的方式
（`mailgun`, `sendcloud` ... 等），因此不同种类的邮件可以通过不同的方法发送。

虽然任何类都可以`include EmailRender`，但建议将邮件全部统一为某个模型的子类，便于管理。

邮件模型同时后台任务，只是controller可以在需要时直接执行`#deliver!`，该方法是`#process!`
的同名方法，因此作为后台任务的邮件模型会直接以完成状态保存，不会被`background_worker`执行。
否则可以选择`#deliver_later!(seconds)`，交由后台发送。（如果controller处于防火墙之后，
无法直接连接外部服务发送邮件，则`#deliver_later`就是唯一可以发送邮件的方法了，
可以指定`seconds = 0`，则运行在防火墙外的服务器上的后台任务会尽快发送邮件）。

spec:lib/email_render

### 邮件发送服务 MailSender

发送服务是一种通用接口，可以接受各种header, html body, text body等参数并`#deliver!`。
不同的发送服务的子类实现通过mailgun，sendcloud等不同第三方服务实现邮件发送。
甚至不同邮件的可以选用不同的发送服务（如注册邮件采用送达率更高的服务）。

### 邮件开发和测试

使用`rake gen:email`可以自动创建邮件模型和相应的模板（两种格式和三种语言，
但可通过`ENV['locales']`和`ENV['formats']`指定）。

测试邮件是否发送成功应该通过验证数据库模型的方法进行。`la-marco-sinatra`还提供了一套
`email_controller`，可在开发环境下挂载到rack以便于确认render后的邮件效果。

## 短信 SMS

TODO: 选择国内合适的服务
