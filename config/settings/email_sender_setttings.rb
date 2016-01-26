# set default senders
# rubocop:disable MethodLength
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
    Mail.defaults do
      delivery_method :smtp, port: 25,
                             address: @address,
                             user_name: @user_name,
                             password: @password,
                             enable_starttls_auto: @enable_starttls_auto,
                             openssl_verify_mode: @openssl_verify_mode
    end

    Emails::AliyunSender.new 'vikkr@em.vikkr.com', 'flzx3kca123'
    # API: 'ACS6DrOgIFfVILhG', 'rDUYHtB5YI', 'xuf@md.vikkr.com'
  end
end
