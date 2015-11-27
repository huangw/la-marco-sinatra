# [Class] EmailRender
#   (lib/email_render.rb)
# vi: foldlevel=1
# created at: 2015-11-27
require 'active_support/concern'

# Find email template file for varies locales and formats,
# parse custom header and render email body
module EmailRender
  extend ActiveSupport::Concern

  included do
    include Mongoid::FieldCandy::EmailField
    email_field :to, required: true

    field :lc, as: :locale, type: Symbol, default: -> { default_locale }
    field :se, as: :send_error, type: String

    validate do
      errors.add :locale,
                 :inclusion if localized? && !available_locales.include?(lc)
    end

    # calculate locale from locales settings
    def default_locale
      return nil unless localized?
      u_lc = I18n.locale.to_sym
      available_locales.include?(u_lc) ? u_lc : available_locales[0]
    end

    def template_dir
      'app/views/'
    end

    def template_basename
      self.class.to_s.underscore
    end

    def available_formats
      [:txt, :html]
    end

    def available_locales
      [:zh, :ja, :en]
    end

    def localized?
      available_locales && available_locales.size > 0
    end

    def template_name(format = nil, locale = nil)
      template_file = template_basename
      template_file += '.' + format unless format.nil?
      File.join(template_dir, template_file)
    end
  end
end
