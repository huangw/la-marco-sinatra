require 'slim'
Slim::Engine.set_options pretty: (ENV['RACK_ENV'] == 'development')

# rubocop:disable MethodLength, CyclomaticComplexity
# Response by render an liquid template
module SlimHelper
  # slim output with mapping to default template files
  def rsp(tpl = nil, opts = {})
    raise 'template id must be a symbol' if tpl && !tpl.is_a?(Symbol)
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

  def partial_block(bname, locals_ = {})
    slim "partial_blocks/#{bname}".to_sym, locals: locals_, layout: false
  end

  # render a obj template
  def present(obj, type = :default, dat = {})
    locales = dat.extract_args(locales: nil)
    dat[:obj] = obj unless dat[:obj]

    dat[:glass] = if dat[:glass]
                    dat[:glass].to_s.underscore
                  elsif obj.respond_to?('_mt') || obj.methods.include?('_mt')
                    obj._mt.underscore
                  else
                    obj.class.to_s.underscore
                  end

    tmpl = File.join('presenters', dat[:glass], type.to_s)

    if locales
      locale = locales[0]
      user_locale = I18n.locale.to_s
      locale = user_locale if locales.map(&:to_s).include?(user_locale)
      tmpl << ".#{locale}"
    end

    slim tmpl.to_sym, locals: dat, layout: false
  end

  def paginate_block(opg, dat = {})
    opg = opg.merge dat
    opg[:present_type] ||= :default

    type = dat.extract_args(:type) || 'table'
    tmpl = File.join('paginate_blocks', type.to_s)

    slim tmpl.to_sym, locals: opg, layout: false
  end

  # set layout files to layout (path relative to views folder)
  # use_layout(false) to disable layout
  def use_layout(layout)
    env['response_layout'] = layout
  end

  def template_dir
    env['template_dir'] ||= Route.default_path(self.class)
  end

  def template_id(tpl = nil, locales = nil)
    tpl ||= request.path_info.sub(/\A\//, '').to_sym
    tpl = :index if tpl.empty?
    return tpl.to_s unless locales

    lc = I18n.default_locale.to_sym
    user_lc = I18n.locale.to_sym
    lc = user_lc if locales.map(&:to_sym).include?(user_lc)
    "#{tpl}.#{lc}".to_s
  end
end
