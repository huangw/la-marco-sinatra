require 'slim'
Slim::Engine.set_options pretty: (ENV['RACK_ENV'] == 'development')

# Response by render an liquid template
module SlimHelper
  # slim output with mapping to default template files
  def rsp(tpl = nil, opts = {})
    fail 'template id must be a symbol' if tpl && !tpl.is_a?(Symbol)
    env['template_id'] = template_id(tpl, opts.delete(:locales))

    use_layout(opts[:layout]) if opts[:layout] # so user can pass false
    opts[:layout] ||= env['response_layout'] if env['response_layout']

    content_type :html, 'charset' => 'utf-8'
    slim File.join(template_dir, env['template_id']).to_sym, opts
  end

  # rsp with halt
  def rsp!(*args)
    halt rsp(*args)
  end

  # `partial page_name` uses
  def partial(pname, lcls = {})
    use_layout(false)
    slim "#{template_dir}/_#{pname}".to_sym, locals: lcls
  end

  # set layout files to layout (path relative to views folder)
  # use_layout(false) to disable layout
  def use_layout(layout)
    env['response_layout'] = layout
  end

  def template_dir
    env['template_dir'] ||= Route.default_path(self.class).gsub('-', '_')
  end

  def template_id(tpl = nil, locales = nil)
    tpl ||= request.path_info.sub(/\A\//, '').gsub('-', '_').to_sym
    tpl = :index if tpl.empty?
    return tpl.to_s unless locales

    lc, user_lc = I18n.default_locale.to_sym, I18n.locale.to_sym
    lc = user_lc if locales.map(&:to_sym).include?(user_lc)
    "#{tpl}.#{lc}".to_s
  end
end
