# [Class] AliyunSender
#   (lib/emails/aliyun_sender.rb)
# vi: foldlevel=1
# created at: 2016-01-02

module Emails
  # Use aliyun mail service to send email
  class MailgunSender
    attr_accessor :access_key_id, :secret, :params

    FIELDS = %w(AccessKeyId password url to cc bcc subject from sender reply-to
                return-path inline)

    def initialize(access_key_id, secret, account, params = {})
      @access_key_id = access_key_id
      @secret = secret
      @account = account
      @params = params
    end

    def deliver!(headers, bodies)
      hsh = {}

      hsh = sign(hsh)
    end

    def sign(hsh)
    end
  end
end
