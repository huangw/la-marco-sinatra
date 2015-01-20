# La-Marco-Sinatra: Sinatra Based Web Framework

## Concept

- `config.ru`实现rack标准，通过`foreman/puma`测试
- `application.rb`加载sinatra application和主要插件
- `Route`机制，独立app（如bluemoon）可无缝加载或移除
- 开发环境下在sinatra logger和测试页加载debug功能（彩色logger，pry debugger）
- 基于`Route`，通过path helper，实现对面包屑的程序化管理
- I18n机制
- slim helper, form和table helper
- 基于stackupper的asset helper和compiler
- API helpers, API测试和文档helper

Center Logger和Email需要数据库支持，放到单独的程序中实现。

## Usage
