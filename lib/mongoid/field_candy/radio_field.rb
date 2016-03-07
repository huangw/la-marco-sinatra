# [Class] EnumField (lib/mongoid/field_candy/radio_field.rb)
# vim: foldlevel=1
# created at: 2015-01-29
require 'active_support/concern'

# Usage:
#
#   radio_field :state, [:active, :inactive], default: :active, bare: true
#   radio_field :state, { a: :active,
#                        i: :inactive }, default: :active, bare: true
#
#   radio_field :state, { 1 => :active, 9 => :inactive }
#
# Use numeric key to set the filed type to Integer, other wise
# the field type will be Symbol.
#
# Set `bare` to true then you can use `active?`, `active!` instead of
# `state_active?` or `state_active!`
#
# record.active?, record.active!
# record.state_in?(:active, :inactive, ...)
#
# Or if the field name is not equal `state`:
#
#   radio_field :alarm, [:on, :off], default: :on
#
# record.alarm_on?, record.alarm_on!, record.alarm_in?(:off)

# mixin mongoid
module Mongoid
  # extensions for custom fields
  module FieldCandy
    # minimalist approach for enum fields
    module RadioField
      extend ActiveSupport::Concern

      included do
        # rubocop:disable LineLength, MethodLength, CyclomaticComplexity
        def self.radio_field(field_name, choices, hsh = {})
          bare = hsh.delete(:bare)

          # normalize choices to key => :value hash
          choice_hash = {}
          if choices.is_a?(Array)
            choices.each { |k| choice_hash[k.to_s.to_sym] = k.to_sym }
          else
            choice_hash = choices.dup
          end

          choices = {}
          choice_hash.each do |k, v|
            k = k.to_sym if k.is_a?(String)
            choices[k] = v.to_sym
          end

          # determine field type (symbol or integer)
          non_nil_keys = choices.keys.select { |k| !k.nil? }
          key_type = nil
          key_type = Integer if non_nil_keys.all? { |k| k.is_a?(Integer) }
          key_type = Symbol if non_nil_keys.all? { |k| k.is_a?(Symbol) }
          raise 'mixed key type for hash keys' if key_type.nil?

          # register field
          field field_name.to_sym, { type: key_type }.merge(hsh)

          # return available choices as normalized key => value hash
          # send(:define_method, "#{field_name}_choices") { choices }
          define_singleton_method("#{field_name}_choices") { choices }

          # return the field value from label
          # send(:define_method, "#{field_name}_value") do |value|
          define_singleton_method("#{field_name}_value") do |value|
            return nil if value.nil?
            val = value.is_a?(String) ? value.to_sym : value
            if key_type == Integer
              val = choices.invert[val] if val.is_a?(Symbol)
            else
              val = choices.invert[val] unless choices.key?(val)
            end
            raise "unknown option #{val}" unless choices.key?(val)
            val
          end

          # getter / setter that always return value
          send(:define_method, field_name) do
            choices[self[field_name.to_sym]]
          end

          send(:define_method, "#{field_name}=") do |val|
            self[field_name.to_sym] = self.class.send("#{field_name}_value", val)
          end

          # check and switch method for each methods, state as method name,
          # but save as `val` as field value
          choices.each do |val, state|
            met = bare ? state : "#{field_name}_#{state}"
            val = key_type == Symbol ? val.to_sym : val.to_i unless val.nil?

            send(:define_method, "#{met}?".to_sym) do
              self[field_name.to_sym] == val
            end

            send(:define_method, "#{met}!".to_sym) do
              update_attributes field_name => self.class.send("#{field_name}_value", val)
            end
          end
        end
      end
    end
  end
end
