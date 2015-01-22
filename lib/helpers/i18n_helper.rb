require 'http_accept_language'
# Directly use t, tt, l and init_locale
module I18nHelper
  def preferred_locale(avails = I18n.available_locales)
    http_accept_language
      .user_preferred_languages.unshift params[:locale] if params[:locale]
    http_accept_language.preferred_language_from(I18n.avails)
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
