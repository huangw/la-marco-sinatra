# encoding: utf-8
require 'tilt'
require 'slim'

# Base on template defined under app/views/presenters,
# render object to html code blocks
module HtmlPresenter
  VIEW_DIR = root_join('app', 'views', 'presenters')

  def to_html(type = :default, dat = {})
    ext, locales = dat.extract_args(tpl_extension: 'slim', locales: nil)
    tmpl = File.join(VIEW_DIR, self.class.to_s.underscore, "#{type}")

    if locales
      locale, user_locale = locales[0], I18n.locale.to_s
      locale = user_locale if locales.map(&:to_s).include?(user_locale)
      tmpl << ".#{locale}"
    end

    Tilt.new("#{tmpl}.#{ext}").render self, locals
  end
end
