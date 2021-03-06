# [Class] EmailRender
#   (lib/email_render.rb)
# vi: foldlevel=1
# created at: 2015-11-27
require 'active_support/concern'
require 'background/job'
require 'liquid'

# Find email template file for varies locales and formats,
# parse custom header and render email body
module Emails
  module Render
    extend ActiveSupport::Concern

    included do
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
        available_locales && !available_locales.empty?
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

      def template_file(format = nil)
        template_file = template_basename
        template_file += ".#{locale}" if locale

        format ||= default_format
        template_file += ".#{format}" # always has a format

        File.join(template_dir, template_file)
      end

      # parse the template
      # ---------------------

      attr_accessor :headers, :bodies

      def valid_fields
        %w(to cc bcc subject from sender_type reply-to return-path inline)
      end

      def read_template(fmt)
        Liquid::Template.parse(
          File.open(template_file(fmt), 'r:utf-8').read
        )
      end

      def parse(extra_headers = {})
        @bodies = {}
        available_formats.each do |fmt|
          body = read_template(fmt).render(to_hash)

          if @headers.nil?
            head, body = body.split("\n\n", 2)
            setup_header(YAML.load(head).merge(extra_headers.stringify_keys))
          end
          @bodies[fmt] = body
        end
      end

      # set email header with valid field checking
      def setup_header(dat)
        @headers = { to: to }
        dat.each do |key, val|
          key = key.to_s.downcase
          raise "invalid field #{key}" unless valid_fields.include?(key)
          @headers[key.to_sym] = val unless val.nil?
        end
      end

      # delivery the email
      # ---------------------
      field :_d_at, type: Time

      # nil if not defined in template file or by extra rendering data
      attr_writer :sender_type
      def sender_type
        hsender = @headers.delete(:sender_type) if @headers
        @sender_type ||= hsender
      end

      def process!
        parse unless @headers
        email_sender(sender_type).deliver!(@headers, @bodies)
        self._d_at = Time.now
      end

      def deliver!
        # this will call process! in the right way
        perform_job!('front-sender')
      end

      def delivered?
        job_state == 10
      end

      def delivered_at
        delivered? && _d_at
      end

      def deliver_later(sec = 0)
        self.not_before = Time.now + sec
        save!
      end
    end
  end
end
