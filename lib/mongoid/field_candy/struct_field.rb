# [Class] StructField
#   (lib/mongoid/field_candy/struct_field.rb)
# vi: foldlevel=1
# created at: 2016-02-23
require 'active_support/concern'

# Mixin mongoid
module Mongoid
  # Field candies
  module FieldCandy
    # Hold one hush struct
    module StructField
      extend ActiveSupport::Concern

      included do
        # Serialize any object into a hash structured via setter,
        # and retrieve object via setter.
        # rubocop:disable MethodLength, CyclomaticComplexity
        def self.struct_field(field_name, opts = {})
          opts.symbolize_keys!
          met = opts.delete(:as)
          raise 'must specify :as' unless met

          # Restricting `_type`s that can setter to this field
          classes = opts.delete(:classes) # allow only those classes
          classes = classes.map(&:to_s).map(&:classify) if classes

          # Setup the field via Mongoid's default field method:
          field field_name.to_sym, opts.merge(type: Hash)

          # Define the getter
          define_method met.to_sym do
            unless instance_variable_get("@_#{field_name}")
              hsh = self[field_name.to_sym] # raw access
              return nil unless hsh
              klass = Object.const_get(hsh['_type'].to_s.classify)
              instance_variable_set("@_#{field_name}", klass.from_hash(hsh))
            end
            instance_variable_get("@_#{field_name}")
          end

          # Define the setter
          define_method "#{met}=".to_sym do |obj|
            # Allow direct assign with hash
            hsh = obj.is_a?(Hash) ? obj : obj.to_hash
            hsh['_type'] ||= obj.class.to_s

            if classes # Check if the object is a allowed instance type
              raise "class #{hsh['_type']} not allowed, should be one of "\
                + classes.join(', ') unless classes.include?(hsh['_type'])
            end

            self[field_name.to_sym] = hsh
            instance_variable_set("@_#{field_name}", nil)
            send(met.to_sym)
          end

          # A callback that saves the in memory instance proxy back into field
          before_update do
            if instance_variable_get("@_#{field_name}")
              send("#{met}=".to_sym, instance_variable_get("@_#{field_name}"))
            end
          end
        end
      end
    end # class StructField
  end # module FieldCandy
end # module Mongoid
