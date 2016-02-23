# I18n settings
require 'i18n'
require 'i18n/backend/fallbacks'

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

# Skip no-existing `:zh` locale from fall-backs path
I18n.fallbacks[:'zh-CN'] = [:zh, :en]
I18n.load_path = Dir.glob(root_join('i18n', '**/*.yml'))
I18n.backend.load_translations
I18n.available_locales
# Follow rails 4 compatible behavior
I18n.enforce_available_locales = true
