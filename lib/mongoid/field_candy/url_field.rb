# [Class] UrlField (lib/mongoid/field_candy/url_field.rb)
# vim: foldlevel=1
# created at: 2015-02-02

require 'active_support/concern'

# mixin mongoid
module Mongoid
  # extensions for custom fields
  module FieldCandy
    # Shortcut for a string formatted url field with basic validation set
    # rubocop:disable LineLength
    module URLField
      extend ActiveSupport::Concern

      included do
        # Options are:
        # - all valid options for mongoid field
        # - required: presence validation, default false
        # - format: format validation, besides the default url validator
        # - unique: uniqueness validation, true or hash, default false
        def self.url_field(field_name, opts = {})
          opts.symbolize_keys!
          req, fmt, uniq = [:required, :format, :unique].map { |k| opts.delete(k) }

          field field_name.to_sym, { type: String }.merge(opts)

          v_opts = { length: { maximum: 2047 }, # IEEE standard maximum length
                     url: true }
          req ? v_opts[:presence] = true : v_opts[:if] = field_name.to_sym
          v_opts[:format] = fmt if fmt
          v_opts[:uniqueness] = uniq if uniq
          field_name = opts[:as] if opts[:as]

          validates field_name.to_sym, v_opts
        end # def
      end # intend
    end # module BoolField
  end
end
