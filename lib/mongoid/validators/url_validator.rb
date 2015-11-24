# encoding: utf-8
require 'uri'

# validates a url by using uri
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, :invalid_url unless url_valid?(value)
  end

  # a URL may be technically well-formed but may
  # not actually be valid, so this checks for both.
  # rubocop:disable all
  def url_valid?(url)
    url = URI.parse(url) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end
end
