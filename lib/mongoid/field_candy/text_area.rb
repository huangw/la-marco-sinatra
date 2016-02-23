# [Class] TextArea
#   (lib/mongoid/field_candy/text_area.rb)
# vi: foldlevel=1
# created at: 2016-02-23

require 'active_support/concern'
require 'sanitize'

# mixin mongoid
module Mongoid
  # field candies
  module FieldCandy
    # String field with certain validation binding
    module TextArea
      extend ActiveSupport::Concern

      included do
        # String (or Integer if you set type: Integer in opts). Valid opts are:
        # - all valid options for mongoid field
        # - min, max: length validation
        # - required: presence validation, default false
        # rubocop:disable LineLength,MethodLength,CyclomaticComplexity
        def self.text_area(field_name, opts = {})
          opts.symbolize_keys!
          min, max, req = [:min, :max, :required].map { |k| opts.delete(k) }
          field field_name.to_sym, { type: String }.merge(opts)

          v_opts = (min || max) ? { length: {} } : {}
          v_opts[:length][:minimum] = min if min
          v_opts[:length][:maximum] = max if max

          req ? v_opts[:presence] = true : v_opts[:if] = field_name.to_sym

          field_name = opts[:as] if opts[:as]
          validates field_name.to_sym, v_opts

          send(:define_method, :"#{field_name}=") do |str|
            self[field_name] = str.nil? ? nil : Sanitize.fragment(str, Sanitize::Config::BASIC)
          end

          send(:define_method, :"#{field_name}") do
            self[field_name].nil? ? nil : self[field_name].simple_format
          end
        end
      end
    end # class TextField
  end # module FieldCandy
end # module Mongoid
