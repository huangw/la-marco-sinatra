# set default senders
def email_sender(type = nil)
  type ||= ENV['RACK_ENV'] == 'production' ? :mailgun : :fake
  case type.to_sym
  when :fake
    Emails::FakeSender.new
  when :mailgun
  end
end
