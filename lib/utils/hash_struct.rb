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
    _struct.merge(h.symbolize_keys).each { |met, v| send("#{met}=", v) }
  end

  # Raw getter and setters
  def [](key)
    instance_variable_get("@#{key}")
  end

  def []=(key, value)
    instance_variable_set("@#{key}", value)
  end

  def to_hash_keys
    _struct.keys.map(&:to_sym)
  end

  def _type
    self.class.to_s
  end

  def _type=(_)
  end

  def to_hash
    hsh = _to_hash to_hash_keys
    yield hsh if block_given?
    hsh['_type'] ||= _type
    hsh
  end

  included do
    include HashSerialize
    class << self
      def struct(hsh)
        hsh = superclass.new._struct.merge(hsh) if superclass < HashStruct
        send(:define_method, :_struct) { hsh.symbolize_keys }
        hsh.keys.each { |k| attr_accessor k }
      end

      def from_hash(hsh)
        new._from_hash(hsh)
      end
    end
  end
end
