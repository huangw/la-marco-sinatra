# [Class] Reflection
#   (lib/mongoid/reflections.rb)
# vi: foldlevel=1
# created at: 2016-03-12

# Mixin Mongoid module
module Mongoid
  # Add field keys list for mongoid document
  module Document
    def field_keys
      keys = []
      self.class.fields.each do |k, f|
        next if k.to_sym == :_id
        key = f.options[:as] || k
        keys << key.to_sym
      end
      keys
    end
  end
end
