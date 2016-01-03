# [Class] AliyunSender
#   (lib/emails/aliyun_sender.rb)
# vi: foldlevel=1
# created at: 2016-01-02
require 'faraday'

module Emails
  # Use aliyun mail service to send email
  class MailgunSender
    attr_accessor :access_key_id, :secret, :account_name

    def initialize(access_key_id, secret, account_name)
      @access_key_id = access_key_id
      @secret = secret
      @account_name = account_name
    end

    def deliver!(headers, bodies)
      # TODO: use smtp to send email
    end
  end
end
