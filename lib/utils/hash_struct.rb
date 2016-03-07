# [Class] HashStruct
#   (lib/mongoid/hash_struct.rb)
# vi: foldlevel=1
# created at: 2016-02-22
require 'active_support/concern'
require 'utils/hash_serialize'

# Implement a simple embeddable mongoid document with hash serialize interface.
module HashStruct
  extend ActiveSupport::Concern

  def initialize(h = {})
    # Initialize with default values defined by `.struct` class method
    _from_hash _struct.merge(h.symbolize_keys)
  end

  # Raw getter and setters that do not affect by method overloading
  def [](key)
    instance_variable_get("@#{key}")
  end

  def []=(key, value)
    instance_variable_set("@#{key}", value)
  end

  # Keys be exposed via `#to_hash` method, default are `:_type` plus
  # all `struct` keys
  def to_hash_keys
    ([:_type] + _struct.keys.map(&:to_sym)).uniq
  end

  # Even `_type` can be overloading by classes implements this interface
  def _type
    self.class.to_s
  end

  # Do nothing. A fake setter for `_from_hash`, make `_type` read only
  def _type=(_)
  end

  def to_hash
    hsh = _to_hash to_hash_keys
    yield hsh if block_given?
    hsh
  end

  included do
    include HashSerialize
    class << self
      def struct(hsh)
        # If the super class also defined `struct`, merge it together.
        # Subclasses can change default values but can not delete keys
        # defined by the super class.
        hsh = superclass.new._struct.merge(hsh) if superclass < HashStruct
        send(:define_method, :_struct) { hsh.symbolize_keys }
        hsh.keys.each { |k| attr_accessor k }
      end

      def from_hash(hsh)
        new(hsh)
      end
    end
  end
end
