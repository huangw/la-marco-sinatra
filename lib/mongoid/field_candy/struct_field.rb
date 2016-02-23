# [Class] StructField
#   (lib/mongoid/field_candy/struct_field.rb)
# vi: foldlevel=1
# created at: 2016-02-23
require 'active_support/concern'

# mixin mongoid
module Mongoid
  # field candies
  module FieldCandy
    # hold one hush struct
    module StructField
      extend ActiveSupport::Concern

      included do
        # Serialize any object into a hash structured and de-serialize
        # by #to_hash / .from_hash
        # rubocop:disable MethodLength, CyclomaticComplexity
        def self.struct_field(field_name, opts = {})
          opts.symbolize_keys!
          met = opts.delete(:as)
          raise 'must specify :as' unless met

          classes = opts.delete(:classes) # allow only those classes
          classes = classes.map(&:to_s).map(&:classify) if classes

          field_name = field_name.to_sym
          field field_name, opts.merge(type: Hash)

          define_method met.to_sym do
            unless instance_variable_get("@_#{field_name}")
              hsh = self[field_name.to_sym] # raw access
              return nil unless hsh
              klass = Object.const_get(hsh['_type'].to_s.classify)
              instance_variable_set("@_#{field_name}", klass.from_hash(hsh))
            end
            instance_variable_get("@_#{field_name}")
          end

          define_method "#{met}=".to_sym do |obj|
            class_name = obj.class.to_s
            if classes # check if the object is a allowed instance type
              raise "class #{class_name} not allowed, should be one of "\
                + classes.join(', ') unless classes.include?(class_name)
            end

            hsh = obj.to_hash
            hsh['_type'] ||= class_name
            self[field_name.to_sym] = hsh
            instance_variable_set("@_#{field_name}", obj.class.from_hash(hsh))
            send(met.to_sym)
          end

          before_update do
            if instance_variable_get("@_#{field_name}")
              send("#{met}=".to_sym,
                   instance_variable_get("@_#{field_name}"))
            end
          end
        end
      end
    end # class TextField
  end # module FieldCandy
end # module Mongoid
