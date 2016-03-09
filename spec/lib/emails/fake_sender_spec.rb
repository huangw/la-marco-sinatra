require 'spec_helper'

describe Emails::FakeSender do
  it 'is the default sender for non-production environment' do
    expect(email_sender).to be_instance_of(Emails::FakeSender)
  end

  describe '#deliver!' do
    it 'always send email with success' do
      memail = Emails::MockEmail.new(to: 'huangw@pe-po.com')
      expect(memail.sender_type).to be_nil

      expect(memail.delivered?).to be_falsey
      memail.deliver!
      expect(memail.delivered?).to be_truthy
    end
  end

  describe '#deliver_later' do
    it 'use background job to send the email' do
      memail = Emails::MockEmail.new(to: 'huangw@pe-po.com')
      expect(memail.sender_type).to be_nil

      expect(memail.delivered?).to be_falsey
      memail.deliver_later(-1)
      expect(memail.job_state).to eq(300)
      Email.perform

      expect(Emails::MockEmail.find(memail._id).delivered?).to be_truthy
    end
  end
end
