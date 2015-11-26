require 'http_accept_language'
# Directly use t, tt, l and init_locale
module I18nHelper
  def preferred_locale(avails = I18n.available_locales)
    hal = HttpAcceptLanguage::Parser.new env['HTTP_ACCEPT_LANGUAGE']
    # rubocop:disable LineLength
    hal.user_preferred_languages.unshift current_user.loc.to_s if respond_to?('current_user') && current_user
    hal.user_preferred_languages.unshift params[:locale] if params[:locale]
    hal.user_preferred_languages = hal.user_preferred_languages.map { |loc| loc.match(/zh/) ? 'zh' : loc }
    hal.preferred_language_from(avails) || 'zh'
  end

  # mapping i18n name space from the logical path
  def tt(msg, opts = {})
    unless opts[:scope]
      opts[:scope] = 'views.' + template_dir.tr('/', '.')
      opts[:scope] += ".#{env['template_id']}" if env['template_id']
    end

    I18n.t msg, opts
  end

  def t(msg, opts = {})
    I18n.t msg, opts
  end

  # layout i18n
  def ltt(msg, opts = {})
    I18n.t 'views.layout.' + msg.to_s, opts
  end

  # flash i18n
  def ftt(msg, opts = {})
    I18n.t 'views.flash.' + msg.to_s, opts
  end

  # TODO: use active record build-in methods
  def matt(msg, opts = {})
    I18n.t 'mongoid.attributes.' + msg.to_s, opts
  end
end
