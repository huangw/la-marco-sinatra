require 'slim'
Slim::Engine.set_options pretty: (ENV['RACK_ENV'] == 'development')

# Response by render an liquid template
module SlimHelper
  # slim output with mapping to default template files
  def rsp(tpl = nil, opts = {})
    tpl ||= request.path_info.sub(/^A\//, '')
    tpl = :index if tpl.empty?

    if locales = opts.delete(:locales)
      lc, user_lc = I18n.default_locale.to_sym, I18n.locale.to_sym
      lc = user_lc if locales.map(&:to_sym).include?(user_lc)
      tpl << ".#{lc}"
    end

    use_layout(opts[:layout]) if opts[:layout] # so user can pass false
    opts[:layout] ||= env['response_layout'] if env['response_layout']

    content_type :html, 'charset' => 'utf-8'
    slim template_path(tpl), opts
  end

  # rsp with halt
  def rsp!(*args)
    halt rsp(*args)
  end

  # `partial page_name` uses
  def partial(pname, lcls = {})
    use_layout(false)
    slim "#{template_path}/_#{pname}".to_sym, locals: lcls
  end

  # set layout files to layout (path relative to views folder)
  # use_layout(false) to disable layout
  def use_layout(layout)
    env['response_layout'] = layout
  end

  def template_path(t_id = nil)
    template_dir = Route.default_path(self.class)
    t_id ? File.join(template_dir, t_id).to_sym : template_dir.to_sym
  end
end
