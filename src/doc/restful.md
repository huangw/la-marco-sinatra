# Restful API and Ajax Controller

## Rack::JsonResponse

`Rack::JsonResponse`是一个rack中间件，将下游app反馈回来的Hash数据转换成Json，同时：

- Merge `env['response_hash']` 到输出的Hash
- 如果下游app抛出异常，将其类别、message等格式化为Json后输出
- 如果错误信息有对应的I18n message，将该message添加到Json输出

spec:lib/rack/json_response

## API Controller

`API::RestfulController`提供了一个嵌入`JsonResponse`之后的Restful API的典型实现，
可以用作API controller的子类。

spec:app/pages/restful_controller

`rspec`通过`rack-test`工具测试服务器的API，因此与cucumber不同，不需要启动服务器。
`ApiTestHelper`提供了简化`rspec`书写的一些便捷方法（如自动解码Json，自动认证等）。

spec:spec/support/helpers/api_test_helper

TODO: 使用aligo工具从Rspec测试自动生成API文档。

## Ajax Controller

TODO: 调整`JsonResponse`的输出，或开发Ajax专用的中间件。
