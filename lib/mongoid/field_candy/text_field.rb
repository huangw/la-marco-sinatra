# [Class] TextField (lib/mongoid/field_candy/text_field.rb)
# vim: foldlevel=1
# created at: 2015-01-30
require 'active_support/concern'
require 'sanitize'

# mixin mongoid
module Mongoid
  # field candies
  module FieldCandy
    # String field with certain validation binding
    module TextField
      extend ActiveSupport::Concern

      included do
        # String (or Integer if you set type: Integer in opts). Valid opts are:
        # - all valid options for mongoid field
        # - min, max: length validation
        # - required: presence validation, default false
        # - format: formant validation
        # - unique: uniqueness validation, true or hash, default false
        # rubocop:disable LineLength,MethodLength,CyclomaticComplexity
        def self.text_field(field_name, opts = {})
          opts.symbolize_keys!
          min, max, req, fmt, uniq = [:min, :max, :required, :format, :unique].map { |k| opts.delete(k) }
          field field_name.to_sym, { type: String }.merge(opts)

          v_opts = (min || max) ? { length: {} } : {}
          v_opts[:length][:minimum] = min if min
          v_opts[:length][:maximum] = max if max

          req ? v_opts[:presence] = true : v_opts[:if] = field_name.to_sym
          v_opts[:format] = fmt if fmt
          v_opts[:uniqueness] = uniq if uniq
          field_name = opts[:as] if opts[:as]

          validates field_name.to_sym, v_opts

          send(:define_method, :"#{field_name}=") do |str|
            self[field_name] = str.nil? ? nil : Sanitize.fragment(str, Sanitize::Config::RESTRICTED)
          end
        end
      end
    end # class TextField
  end # module FieldCandy
end # module Mongoid
