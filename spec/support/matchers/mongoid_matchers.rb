# encoding: utf-8
require 'rspec/expectations'

RSpec::Matchers.define :have_validate_error do |expected|
  match do |actual|
    valid = actual.valid?
    expected = I18n.t("errors.messages.#{expected}") if expected.is_a?(Symbol)
    !valid && actual.errors.messages[@field].include?(expected)
  end

  failure_message do |actual|
    "expected validate error of '#{expected}' on :#{@field}, but the errors are:\n" + actual.errors.messages[@field].inspect
  end

  chain :on do |field|
    @field = field.to_sym
  end
end
