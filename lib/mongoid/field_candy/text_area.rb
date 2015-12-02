# [Class] TextArea (lib/mongoid/field_candy/text_area.rb)
# vim: foldlevel=3
# created at: 2015-01-30
require 'active_support/concern'
require 'mongoid/ordered_list'

# mixin mongoid
module Mongoid
  # mixin ordered list
  module OrderedList
    # Add auto text detection when add to origin Proxy class
    class TextProxy < Proxy
      def add(blk, opts = {})
        if blk.is_a?(String)
          opts.stringify_keys!
          type = opts.delete('_type') || 'P'
          blk = TextBlock.new text: blk, _type: type
        end
        super(blk, opts)
      end

      def decode(hsh)
        return TextBlock.new(hsh) if TextBlock::TYPES.include?(hsh['_type'])
        super(hsh)
      end

      def from_hash(hsh)
        super hsh.map do |itm|
          item.is_a?(String) ? TextBlock.new(text: itm, _type: 'P') : item
        end
      end

      def text_size
        blist.inject(0) { |a, e| a + e['text'].size if e['text'] }
      end
      alias_method :length, :text_size
    end
  end

  # field candies
  module FieldCandy
    # String field with certain validation binding
    module TextArea
      extend ActiveSupport::Concern

      included do
        include Mongoid::OrderedList
        # An ordered list of `P` type text blocks with following opts:
        # - all valid options for ordered_list and mongoid field
        # - min, max: length validation, default is max: 300, min: nil
        #
        # Set a positive min to mark it as required
        # rubocop:disable CyclomaticComplexity
        def self.text_area(field_name, opts = {})
          opts.symbolize_keys!
          opts = { proxy: Mongoid::OrderedList::TextProxy }.merge opts
          min, max = [:min, :max].map { |k| opts.delete(k) }

          ordered_list field_name.to_sym, opts
          v_opts = (min || max) ? { length: {} } : {}
          v_opts[:length][:minimum] = min if min
          v_opts[:length][:maximum] = max if max

          validates opts[:as].to_sym, v_opts if min || max
        end
      end # include
    end # class TextArea
  end # module FieldCandy
end # module Mongoid
