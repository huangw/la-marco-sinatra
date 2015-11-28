# [Class] EmailRender
#   (lib/email_render.rb)
# vi: foldlevel=1
# created at: 2015-11-27
require 'active_support/concern'
require 'background/job'

# Find email template file for varies locales and formats,
# parse custom header and render email body
module EmailRender
  extend ActiveSupport::Concern

  included do
    attr_accessor :headers, :bodies
    attr_writer :sender

    include Background::Job

    include Mongoid::FieldCandy::EmailField
    email_field :to, required: true

    field :lc, as: :locale, type: Symbol, default: -> { default_locale }
    field :o_at, as: :opened_at, type: Time

    validate do
      errors.add :locale,
                 :inclusion if localized? && !available_locales.include?(lc)
    end

    # Override those methods in subclasses
    # ---------------------------------------

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

    # find template
    # ---------------

    def localized?
      available_locales && available_locales.size > 0
    end

    # calculate locale from locales settings
    def default_locale
      return nil unless localized?
      u_lc = I18n.locale.to_sym
      available_locales.include?(u_lc) ? u_lc : available_locales[0]
    end

    def default_format
      available_formats.first
    end

    def template_name(format = nil, locale = nil)
      template_file = template_basename

      locale ||= default_locale if localized? # may has a locale
      template_file += ".#{locale}" if locale

      format ||= default_format
      template_file += ".#{format}" # always has a format

      File.join(template_dir, template_file)
    end

    # parse the template
    # ---------------------

    def valid_fields
      %w(to cc bcc subject from sender reply-to return-path inline)
    end

    def parse(extra_headers = {})
      @bodies = {}
      available_formats.each do |fmt|
        body = Liquid::Template.parse(
          File.open(template_file(fmt), 'r:utf-8').read).render(to_hash)

        if @headers.nil?
          head, body = body.split("\n\n", 2)
          setup_header(YAML.load(head).merge(extra_headers.stringify_keys))
        end
        @bodies[fmt] = body
      end
    end

    def setup_header(dat)
      @headers = {}
      dat.each do |key, val|
        fail "invalid field #{key}" unless valid_fields.include?(key.to_s)
        @headers[key.to_sym] = val unless val.nil?
      end
    end

    # delivery the email
    # ---------------------

    # default sender defined at `config/settings/email_sender_settings`
    def sender
      @sender ||= default_sender
    end

    def process!
      sender.deliver!(@headers, @bodies)
    end
    alias_method :deliver!, :process!

    def deliver_later(sec = 0)
      self.not_before = Time.now + sec
      save!
    end
  end
end
