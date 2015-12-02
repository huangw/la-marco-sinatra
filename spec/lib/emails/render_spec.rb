require 'spec_helper'
require 'emails/render'

class MockEmailLessLocale < Emails::MockEmail
  def available_locales
    [:de, :it]
  end
end

class MockEmailWithoutLocale < Emails::MockEmail
  def available_locales
    []
  end
end

describe Emails::Render do
  subject(:email) { Emails::MockEmail.new to: 'huangw@pe-po.com' }
  describe '#to' do
    it 'is required' do
      expect(Emails::MockEmail.new).to have_validate_error(:blank).on(:to)
    end
  end

  describe '#locale' do
    it 'equals to current locale by default' do
      expect(email.locale).to eq(I18n.locale.to_sym)
    end

    it 'if current locale not supported, to the first available locale' do
      expect(MockEmailLessLocale.new.locale).to eq(:de)
    end

    it 'can not be set to unsupported locale' do
      email.locale = :it
      expect(email).to have_validate_error(:inclusion).on(:locale)
    end
  end

  describe '#template_file' do
    it 'return the template for render the email model' do
      expect(email.template_file).to eq('app/views/emails/mock_email.en.txt')
      expect(email.template_file(:html)).to eq('app/views/emails/mock_email.en.html')
      expect(email.template_file(:html, :fr)).to eq('app/views/emails/mock_email.fr.html')
    end

    it 'return the first locale as the default locale' do
      expect(MockEmailLessLocale.new.template_file).to eq('app/views/mock_email_less_locale.de.txt')
      expect(MockEmailLessLocale.new.template_file(:html)).to eq('app/views/mock_email_less_locale.de.html')
    end

    it 'supports template without locale' do
      expect(MockEmailWithoutLocale.new.template_file).to eq('app/views/mock_email_without_locale.txt')
      expect(MockEmailWithoutLocale.new.template_file(:html)).to eq('app/views/mock_email_without_locale.html')
    end
  end

  describe '#parse' do
    it 'render the template to #headers/#bodies for default locale' do
      email.parse
      expect(email.headers[:subject]).to eq('Email for Emails::MockEmail')
      expect(email.headers[:from]).to eq('test@vikkr.com')
      expect(email.bodies[:txt]).to match('Email for Emails::MockEmail, to huangw@pe-po.com')
      expect(email.bodies[:html]).to match('Email for Emails::MockEmail')
    end
  end
end
