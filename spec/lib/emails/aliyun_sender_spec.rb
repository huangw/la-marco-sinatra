require 'spec_helper'

describe Emails::AliyunSender do
  describe '#deliver!' do
    it 'aliyun send email' do
      to = ENV['TO'] || 'xf19831119@126.com'
      Emails::MockEmail.new(sender_type: :aliyun, to: to).deliver!
    end
  end
end
