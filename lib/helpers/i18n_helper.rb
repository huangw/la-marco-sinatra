require 'http_accept_language'
# Directly use t, tt, l and init_locale
module I18nHelper
  def preferred_locale(avails = I18n.available_locales)
    hal = HttpAcceptLanguage::Parser.new env["HTTP_ACCEPT_LANGUAGE"]
    hal.user_preferred_languages.unshift params[:locale] if params[:locale]
    hal.preferred_language_from(avails)
  end

  # mapping i18n name space from the logical path
  def tt()
    # TODO: a
  end

  def t(*args)
    I18n.t(*args)
  end

  def l(*args)
    I18n.l(*args)
  end
end
