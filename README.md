# La-Marco-Sinatra: Sinatra Based Web Framework

## Concept

- `config.ru`实现rack标准，通过`foreman/puma`测试
- `application.rb`加载sinatra application和主要插件
- 开发环境下在sinatra logger和测试页加载更多debug功能（彩色logger，pry debugger）
- `Route`和application内的`path, on_path?`机制，实现对面包屑的程序化管理
- 符合rack标准的独立app（如bluemoon）可不需要设置，自动加载到`Route`或从中移除
- slim helper, form和table helper
- 基于stackupper的asset helper和compiler
- API helpers

Center Logger和Email需要数据库支持，放到单独的程序中实现。

## Usage
