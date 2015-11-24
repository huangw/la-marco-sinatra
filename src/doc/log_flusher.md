# Log Flusher

## LaBacktraceCleaner

基于ActiveSupport的BacktraceCleaner，去除trace中的不必要信息。

spec:lib/utils/la_backtrace_cleaner

## LaBufferedLogger

`BufferedLogger`是为便于在`rack.logger`中使用而设计的。

**注意** 一定在sinatra的configuration里`set :logging, nil`。

一个BufferedLogger对象初始化后，会缓存所有信息至内部一个数组，直到到达阈值
（默认100）时才会flush!到输出（默认采用`LogStash.logger`，开发环境输出到控制台，
生成环境输出到ELK服务器）。

LaBufferedLogger实现标准RubyLogger所支持的所有severity，包括`:unknown`，
支持直接接收Exception对象作为message：

    logger.warn 'some detailed message'
    logger.error RuntimeError.new('error message')

另外支持`event(type, message, opts)`用于接收任何类型的event，以及`access`记录包含
request信息的access log。`type`可为合法的class名或任意字符串。

`LaBufferedLogger`将上述log信息保存在`msgs`数组，并在调用flush!时默认输出到控制台，
并在调用flush!时其它类可以扩展并重载`flash!`方法，以输出到文件或保存log信息到数据库。

spec:lib/la_buffered_logger

## LogFlusher

是一个Rack中间件，记录下游RackApp的执行时间，并在Log信息中添加`request`的相关信息。

spec:lib/rack/log_flusher
