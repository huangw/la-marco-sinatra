require 'spec_helper'
require 'email_render'

class MockEmail
  include Mongoid::Document
  include EmailRender
end

class MockEmailLessLocale < MockEmail
  def available_locales
    [:de, :it]
  end
end

describe EmailRender do
  subject(:email) { MockEmail.new to: 'huangw@pe-po.com' }
  describe '#to' do
    it 'is required' do
      expect(MockEmail.new).to have_validate_error(:blank).on(:to)
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
end
