# 修正Sinatra（其实是Temple gem）报错页面的错误

寻找报错的`show_exceptions.rb`文件（一般在`~/.rvm/.../gems/.../`下面），在报错的34行左右上方加上`body = [body] if body.is_a?(String)`一行，看上去像这样：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~ruby
env["rack.errors"] = errors
body = [body] if body.is_a?(String)

[500,
 {"Content-Type" => content_type,
  "Content-Length" => Rack::Utils.bytesize(body.join).to_s},
 body]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
