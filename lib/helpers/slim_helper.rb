require 'slim'
Slim::Engine.set_options pretty: (ENV['RACK_ENV'] == 'development')

# response by render an liquid template
module SlimHelper
  # scope template sub-directory from class name:
  #   UserPage => 'views/users', PersonController => 'views/peoples/'
  # rubocop:disable LineLength, MethodLength, CyclomaticComplexity, Metrics/PerceivedComplexity
  def rsp(tpl, opts = {})
    fail 'template filename must be a symbol' unless tpl.is_a?(Symbol)
    env['template_id'] = tpl
    tpl = "#{logic_path}/#{tpl}"

    if opts[:locales]
      locale = opts[:locales][0]
      opts[:locales].each { |lc| locale = lc if lc.to_s == I18n.locale.to_s }
      tpl << ".#{locale}"
      opts.delete(:locales)
    end

    [:notice, :alert, :warning, :error, :info, :success].each do |fkey|
      flash.now[fkey] = opts.delete(fkey) if opts[fkey]
    end

    use_layout(opts[:layout]) if opts[:layout]
    opts[:layout] = env['response_layout'] if env['response_layout']

    opts[:locals] = common_rsp.merge(opts[:locals] || {})
    content_type :html, 'charset' => 'utf-8'
    slim tpl.to_sym, opts
  end

  def common_rsp
    env['common_rsp'] ||= {}
  end

  # rsp with halt
  def hsp(tpl, opts = {})
    halt rsp(tpl, opts)
  end

  def partial(pname, locals_ = {})
    slim "#{logic_path}/_#{pname}".to_sym, locals: locals_, layout: false
  end

  def partial_block(bname, locals_ = {})
    slim "partial_blocks/#{bname}".to_sym, locals: locals_, layout: false
  end

  # set layout files to layout (path relative to views folder)
  def use_layout(layout)
    env['response_layout'] = layout
  end

  # from the class name, calculate logic path for template files
  def logic_path(class_ = nil, met = nil)
    class_ ||= self.class
    met = met ? '/' + met : ''
    class_.to_s.underscore
      .gsub(/_(page|controller)$/, '').gsub('_', '/').pluralize + met
  end
end
