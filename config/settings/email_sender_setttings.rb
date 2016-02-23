# set default senders
# rubocop:disable MethodLength
require 'mail'

Mail.defaults do
  delivery_method :smtp, port: 25,
                         address: 'smtp.dm.aliyun.com',
                         user_name: 'vikkr@em.vikkr.com',
                         password: 'flzx3kca123',
                         enable_starttls_auto: false,
                         openssl_verify_mode: 'none'
end

def email_sender(type = nil)
  type ||= ENV['RACK_ENV'] == 'production' ? :mailgun : :fake
  case type.to_sym
  when :fake
    Emails::FakeSender.new
  when :mailgun
    Emails::MailgunSender.new 'key-7654ed816c89028086db2d8e985e7aa6',
                              'sandbox2d1e98c084ad4393831175520a81b3c5.'\
                              'mailgun.org'
  when :aliyun
    Emails::AliyunSender.new 'vikkr@em.vikkr.com'
  end
end
