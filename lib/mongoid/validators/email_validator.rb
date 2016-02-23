# encoding: utf-8
require 'uri'

# validates a url by using uri
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, :invalid_email unless email_valid?(value)
  end

  # Simple validation
  def email_valid?(email)
    email && email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
  end
end
