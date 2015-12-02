# [Class] BitField (lib/mongoid/field_candy/checkbox_field.rb)
# vim: foldlevel=1
# created at: 2015-01-29
require 'active_support/concern'

# Usage:
#
#     checkbox_field :setting, [:a, :b, :c], default_on: [:c]
#
# in this example, `:a` is 1 if set, :b is 2, :c is 4
#
# Add new options in the tail of the array, like:
#
#     checkbox_field :setting, [:a, :b, :c, :d], default_on: [:c, :d
#
# do not affect existing values in the database.
#
# mixin into mongoid
module Mongoid
  # extensions for custom fields
  module FieldCandy
    # create an bitwise field with pre-settings and hook functions
    # rubocop:disable LineLength,MethodLength,CyclomaticComplexity
    module CheckboxField
      extend ActiveSupport::Concern

      included do
        def self.checkbox_field(field_name, keys, opts = {})
          fail 'keys not defined' unless keys.is_a?(Array)
          default_on = opts.delete(:default_on)
          opts[:default] ||= 0

          if default_on
            default_on = [default_on] if default_on.is_a?(Symbol)
            kmap = keys.map(&:to_sym).reverse
            default_on.each do |bit|
              opts[:default] += 2**(kmap.index(bit.to_sym))
            end
          end

          field field_name.to_sym, { type: Integer }.merge(opts)
          # get the string form of the bit list
          send(:define_method, "#{field_name}_keys".to_sym) do
            khsh = {}
            keys.each_with_index do |k, i|
              khsh[k.to_sym] = 2**i
            end
            khsh
          end

          # get the string form of the bit list
          send(:define_method, "#{field_name}_bits".to_sym) do
            format "%0#{keys.size}d", send(field_name.to_sym).to_s(2)
          end

          send(:define_method, "#{field_name}_offset".to_sym) do |bit|
            fail "wrong key #{bit}, keys are #{keys.join ', '}" unless keys.map(&:to_s).include?(bit.to_s)
            keys.map(&:to_sym).index(bit.to_sym)
          end

          # get the string firm of the bit
          send(:define_method, "#{field_name}_on?".to_sym) do |bit|
            send("#{field_name}_bits".to_sym)[send("#{field_name}_offset".to_sym, bit)] == '1'
          end

          # check whether the corresponding bit is set
          send(:define_method, "#{field_name}_on!".to_sym) do |bit|
            bstr = send("#{field_name}_bits".to_sym).dup
            bstr[send("#{field_name}_offset".to_sym, bit)] = '1'
            # send("#{field_name}=".to_sym, bstr.to_i(2))
            update_attributes!(field_name => bstr.to_i(2))
          end

          send(:define_method, "#{field_name}_only!".to_sym) do |bit|
            bstr = format "%0#{keys.size}d", 0
            bstr[send("#{field_name}_offset".to_sym, bit)] = '1'
            # send("#{field_name}=".to_sym, bstr.to_i(2))
            update_attributes!(field_name => bstr.to_i(2))
          end

          send(:define_method, "#{field_name}_off!".to_sym) do |bit|
            bstr = send("#{field_name}_bits".to_sym).dup
            bstr[send("#{field_name}_offset".to_sym, bit)] = '0'
            update_attributes!(field_name => bstr.to_i(2))
          end

          send(:define_method, "#{field_name}_switch!".to_sym) do |bit|
            bstr = send("#{field_name}_bits".to_sym).dup
            bstr[send("#{field_name}_offset".to_sym, bit)] = send("#{field_name}_on?".to_sym, bit) ? '0' : '1'
            update_attributes!(field_name => bstr.to_i(2))
          end

          send(:define_method, "#{field_name}_h".to_sym) do
            keys.each_with_object({}) { |bit, hsh| hsh[bit.to_s] = send("#{field_name}_on?", bit) ? 'on' : 'off' }
          end

          keys.each do |bit|
            send(:define_method, "#{field_name}_#{bit}?") do
              send("#{field_name}_on?", bit)
            end

            send(:define_method, "#{field_name}_#{bit}!") do |r = true|
              r ? send("#{field_name}_on!", bit) : send("#{field_name}_off!", bit)
            end
          end # each bit
        end # method

        class << self;
          alias_method :checkbox_field, :checkbox_field
        end
      end # included
    end # CheckboxField
  end
end
