require 'spec_helper'

describe Emails::MailgunSender do
  describe 'global #email_sender(:mailgun)' do
    it 'initilaize the mailgun sender object with api passphrase' do
      client = email_sender(:mailgun)
      expect(client.api_key.size).to be > 10
      expect(client.domain.size).to be > 10
    end
  end

  describe '#deliver!', slow: true do
    it 'send email with proper body' do
      Emails::MockEmail.new(sender_type: :mailgun, to: 'huangw@pe-po.com').deliver!
    end
  end
end
