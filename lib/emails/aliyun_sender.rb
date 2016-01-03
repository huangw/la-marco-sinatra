# [Class] AliyunSender
#   (lib/emails/aliyun_sender.rb)
# vi: foldlevel=1
# created at: 2016-01-02
require 'mail'

module Emails
  # Use aliyun mail service to send email
  class AliyunSender
    attr_accessor :url, :account, :passwd

    def initialize(url, account, passwd)
      @url = url
      @account = account
      @passwd = passwd
    end

    def deliver!(headers, bodies)
      # TODO: use smtp to send email
    end
  end
end
