# [Class] AliyunSender
#   (lib/emails/aliyun_sender.rb)
# vi: foldlevel=1
# created at: 2016-01-02

module Emails
  # Use aliyun mail service to send email
  class AliyunSender
    attr_accessor :from_addr

    def initialize(from_addr)
      @from_addr = from_addr
    end

    # rubocop:disable MethodLength
    def deliver!(headers, bodies)
      from_addr = @from_addr
      Mail.deliver(from_addr) do
        to headers[:to]
        from from_addr
        subject headers[:subject]
        text_part do
          body bodies[:txt]
        end
        html_part do
          body bodies[:html]
        end
      end
    end
  end
end
