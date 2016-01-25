require 'spec_helper'

describe Emails::AliyunSender do
  describe '#deliver!' do
    it 'aliyun send email  ' do
      Emails::MockEmail.new(sender_type: :aliyun, to: 'xf19831119@126.com').deliver!
    end
  end
end
