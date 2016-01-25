# [Class] AliyunSender
#   (lib/emails/aliyun_sender.rb)
# vi: foldlevel=1
# created at: 2016-01-02
require 'mail'

module Emails
  # Use aliyun mail service to send email
  class AliyunSender
    attr_accessor  :user_name, :password, :params

    def initialize( user_name, password, params = {})
      @port = 25
      @address = "smtp.dm.aliyun.com"
      @user_name = user_name
      @password = password
      @enable_starttls_auto = false
      @openssl_verify_mode = 'none'
      @params = params
    end

    def deliver!(headers, bodies)
      Mail.defaults do
        delivery_method :smtp, {
                                 :port      => @port,
                                 :address   => @address,
                                 :user_name => @user_name,
                                 :password  => @password,
                                 :enable_starttls_auto => @enable_starttls_auto,
                                 :openssl_verify_mode => @openssl_verify_mode,
                             }
      end
      mail = Mail.deliver do
        to       headers[:to]
        from     headers[:from]
        subject  headers[:subject]
        
        text_part do
          body  bodies[:txt]
        end

        html_part do
          body  bodies[:html]
        end
      end
    end
  end
end
