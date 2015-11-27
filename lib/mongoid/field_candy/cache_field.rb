# [Class] StructField (lib/mongoid/field_candy/struct_field.rb)
# vim: foldlevel=1
# created at: 2015-04-25
require 'active_support/concern'

# mixin mongoid
module Mongoid
  # field candies
  module FieldCandy
    # hold one hush struct
    module CacheField
      extend ActiveSupport::Concern

      included do
        # Serialize any object into a hash structured and de-serialize
        # by .from_cache
        # rubocop:disable LineLength, MethodLength, CyclomaticComplexity
        def self.cache_field(field_name, opts = {})
          opts.symbolize_keys!
          met = opts.delete(:as)
          class_name = opts.delete(:class_name)
          callback = opts.delete(:callback)

          fail 'must specify :as' unless met

          field_name = field_name.to_sym
          field field_name, opts.merge(type: Hash)

          define_method met.to_sym do
            unless instance_variable_get("@_#{field_name}")
              hsh = send(field_name)
              return nil unless hsh
              type = hsh['_type'] || class_name
              return hsh unless type
              klass = Object.const_get(type.to_s.classify)
              instance_variable_set("@_#{field_name}", klass.from_cache(hsh))
            end
            instance_variable_get("@_#{field_name}")
          end

          define_method "#{met}=".to_sym do |obj|
            if class_name
              klass = Object.const_get(class_name.to_s.classify)
              obj_class = obj.is_a?(Hash) ? Object.const_get(obj['_type']) : obj.class
              fail "must be a '#{class_name}'" unless obj_class <= klass
            end

            hsh = obj.is_a?(Hash) ? obj : obj.to_cache
            hsh['_type'] ||= obj.class.to_s
            send("#{field_name}=".to_sym, hsh)
            send(met.to_sym)
          end

          if callback
            before_update do
              if instance_variable_get("@_#{field_name}")
                send("#{met}=".to_sym,
                     instance_variable_get("@_#{field_name}"))
              end
            end
          end
        end
      end
    end # class TextField
  end # module FieldCandy
end # module Mongoid
