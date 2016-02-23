# Rack::Session::Mongoid

使用Mognoid 5.0存取session数据。数据默认保存在`:default` client的
`:rack_session_rack_session` collection，直接存储Hash，没有序列化。

TODO: 允许修改collection，自动测试。

spec:lib/rack/session/mongoid

`localhost:8080/counter`有一个简单的测试例子，实现了一个每次刷新都递增1的计数器。

spec:app/pages/counter_page
