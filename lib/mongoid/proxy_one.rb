# [Class] ProxyOne
#   (lib/mongoid/proxy_one.rb)
# vi: foldlevel=1
# created at: 2016-02-27
require 'active_support/concern'

# Minxin mongoid
module Mongoid
  # Regist a `has_one` relationship to Mongoid::Document
  module ProxyOne
    extend ActiveSupport::Concern

    included do
      # Serialize any object into a hash structured via setter,
      # and retrieve object via setter.
      # rubocop:disable MethodLength, CyclomaticComplexity
      def self.proxy_one(met, opts = {})
        opts.symbolize_keys!
        field_name = opts.delete(:to) || "_#{met}"
        mclass = opts.delete(:class_name) || met # the master class name

        # determine the proxy type to save
        p_type = opts.delete(:type)
        raise 'can not use :as for proxy_one field' if opts.delete(:as)

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

        define_method "#{met}!".to_sym do
          update_attributes met.to_sym => send(met.to_sym).send(:'master!')
          send(met.to_sym)
        end

        # Define the setter
        define_method "#{met}=".to_sym do |obj|
          instance_variable_set("@_#{field_name}", nil)
          return self[field_name.to_sym] = nil if obj.nil?

          # Allow direct assign with hash
          unless obj.is_a?(DataProxy)
            raise 'a data proxy or `:type` is required' unless p_type
            obj = Object.const_get(p_type.to_s.classify).new(obj)
          end

          raise 'not a data proxy' unless obj.is_a?(DataProxy)

          mclass = Object.const_get(mclass.to_s.classify)
          raise 'not a proxy for ' \
                "#{obj.master_class}" unless obj.master_class <= mclass

          self[field_name.to_sym] = obj.to_hash
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
  end
end
