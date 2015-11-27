require 'active_support/concern'

# Usage:
#
#   bool_field :active, default: true,
#                       inverse_by: :inactive,
#                       inverse_as: :not_active
#
# record.active?
# record.active!
# record.inactive! # or: record.active = false
# record.not_active?

# mixin mongoid
module Mongoid
  # extensions for custom fields
  module FieldCandy
    # minimalist approach for boolean fields
    # rubocop:disable MethodLength
    module BoolField
      extend ActiveSupport::Concern

      included do
        def self.bool_field(met, hsh = {})
          inv_met = hsh.delete(:inverse_by)
          inv_chkr = hsh.delete(:inverse_as)
          met_name = hsh[:as] || met
          field met.to_sym, { type: Boolean }.merge(hsh)

          send(:define_method, "#{met_name}?".to_sym) do
            send(met.to_sym)
          end

          send(:define_method, "#{met_name}!".to_sym) do |arg = true|
            update_attributes met => (arg ? true : false)
          end

          if inv_met
            send(:define_method, "#{inv_met.to_s.sub(/\!\Z/, '')}!".to_sym) do
              update_attributes met => false
            end
          end

          if inv_chkr
            send(:define_method, "#{inv_chkr.to_s.sub(/\?\Z/, '')}?".to_sym) do
              send(met.to_sym) ? false : true
            end
          end
        end # def
      end # intend
    end # module BoolField
  end
end
