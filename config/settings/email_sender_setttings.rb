# set default senders
def email_sender(_type = nil)
  type ||= ENV['RACK_ENV'] == 'production' ? :mailgun : :fake
  case type.to_sym
  when :fake
  when :mailgun
  end
end
