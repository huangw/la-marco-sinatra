# [Class] MailgunSender (lib/senders/mailgun_sender.rb)
# vim: foldlevel=1
# created at: 2015-02-03
require 'faraday'

# Use mailgun send email
class MailgunSender
  def initialize(options = {})
    # TODO: initialize mailgun sender clinet with authenticate information
  end

  def deliver!(headers_, bodies_)
    # TODO: send email via mailgun sender with extra header and bodies
  end
end
