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
    Emails::AliyunSender.new # TODO: smtp account and password
    # API: 'ACS6DrOgIFfVILhG', 'rDUYHtB5YI', 'xuf@md.vikkr.com'
  end
end
