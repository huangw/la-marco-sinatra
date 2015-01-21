# 修正Sinatra报错页面的错误

这个其实是Temple gem的错误，以前版本有过修正，最近又回来了。再官方修改之前可先用下面的办法自己修正：

寻找报错的`show_exceptions.rb`文件（一般在`~/.rvm/.../gems/.../`下面），在报错的34行左右上方加上`body = [body] if body.is_a?(String)`一行，看上去像这样：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~ruby
env["rack.errors"] = errors
body = [body] if body.is_a?(String)

[500,
 {"Content-Type" => content_type,
  "Content-Length" => Rack::Utils.bytesize(body.join).to_s},
 body]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

可以顺便改一下下面ERB代码的部分，修改显示的错误信息backtrace中`filename`的部分，把不是来自`gems`的也就是本地代码高亮一下（218行左右）：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~ruby
<li class="frame-info <%= frame_class(frame) %>">
  <code>
    <% if frame.filename.match(/gems/) %>
      <%=h frame.filename %>
    <% else %>
      <b style="color: red"><%=h frame.filename %></b>
    <% end %>
  </code> in
    <code><strong><%=h frame.function %></strong></code>
</li>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
