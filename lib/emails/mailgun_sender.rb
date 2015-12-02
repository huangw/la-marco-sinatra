# [Class] MailgunSender (lib/senders/mailgun_sender.rb)
# vim: foldlevel=1
# created at: 2015-02-03
require 'mailgun'

module Emails
  # Use mailgun send email
  class MailgunSender
    attr_accessor :api_key, :domain, :params

    FIELDS = %w(app_key password url to cc bcc subject from sender reply-to
                return-path inline)

    def initialize(api_key, domain, params = {})
      @api_key = api_key
      @domain = domain
      @params = params
    end

    def deliver!(headers, bodies)
      merge_parameters!(headers)
      [:txt, :html].each { |t| @params[t] = bodies[t] if bodies[t] }
      Mailgun::Client.new(api_key).send_message domain, @params
    end

    def merge_parameters!(hsh)
      hsh.each do |k, v|
        k = k.to_s.downcase
        fail "unknown field #{k}" unless FIELDS.include?(k)
        @params[k.to_sym] = v
      end
    end
  end
end
