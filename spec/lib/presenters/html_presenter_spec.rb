require 'spec_helper'
require 'presenters/html_presenter'

class MockEmail
  include HtmlPresenter

  def title
    'mock_email'
  end
end

describe HtmlPresenter do
  it 'default slim template' do
    em = MockEmail.new

    expect(em.to_html).to eq("<div class=\"default\">mock_email</div>")
    expect(em.to_html(:list)).to eq("<div class=\"list\">mock_email</div>")
  end

  it 'not exits locale' do
    em = MockEmail.new
    expect{ em.to_html(:default, locales: ['fr']) }.to raise_error(Errno::ENOENT)
  end

  it 'not exits type' do
    em = MockEmail.new
    expect{ em.to_html(:test) }.to raise_error(Errno::ENOENT)
  end

  it 'given a list locales' do
    em = MockEmail.new

    I18n.locale = :en
    expect(em.to_html(:default, locales: ['zh', 'en', 'ja'])).to eq("<div class=\"default_en\">mock_email</div>")

    I18n.locale = :zh
    expect(em.to_html(:default, locales: [:zh, :en, :ja])).to eq("<div class=\"default_zh\">mock_email</div>")
  end

  it 'given a list locales' do
    em = MockEmail.new

    expect(em.to_html(:dat, name: 'test')).to eq("<div class=\"dat\">test</div>")
  end
end