# [Class] HashStruct (lib/utils/hash_struct.rb)
# vim: foldlevel=1
# created at: 2015-01-29
require 'active_support/concern'

# A basic module that can convert between hash and objects
# require user class implements an `struct()` method
# rubocop:disable CyclomaticComplexity, MethodLength
module HashStruct
  extend ActiveSupport::Concern

  def initialize(h = {})
    struct.keys.each { |k| self.class.class_eval { attr_accessor k.to_sym } }
    hsh = struct.merge(h).stringify_keys
    hsh['_type'] ||= self.class.to_s if to_hash_keys.include?(:_type)
    from_hash(hsh)
  end

  def [](key)
    send(key.to_sym)
  end

  def []=(key, value)
    send("#{key}=".to_sym, value)
  end

  # Use hash to build object recursively
  def from_hash(h)
    return self unless h
    h.each do |k, v|
      if v.is_a?(Hash) && v['_type']
        if TextBlock::TYPES.include?(v['_type'].to_s)
          klass = TextBlock
        else
          klass = Object.const_get(v['_type'].to_s.classify)
        end
        # recursively de-serialize by .from_hash method
        v = klass.demongoize(v) if klass.respond_to?(:demongoize)
      end

      v = send(:"convert_#{k}", v) if respond_to?(:"convert_#{k}") && !v.nil?
      send(:"#{k}=", v)
    end
    self
  end

  def to_hash_keys
    struct.keys.map(&:to_sym)
  end

  def to_hash(keys = nil)
    keys = to_hash_keys if keys.nil? || keys.is_a?(Symbol) # :default, ...
    hsh = {}
    keys.each do |k|
      value = send(k.to_sym)
      next if value.nil?
      if value.is_a?(Hash)
        hsh[k.to_s] = value
      else
        hsh[k.to_s] = value.respond_to?(:mongoize) ? value.mongoize : value
      end
    end
    yield hsh if block_given?
    hsh
  end
  alias_method :to_cache, :to_hash
  alias_method :to_embed, :to_hash

  def mongoize
    hsh = to_hash
    hsh.keys.empty? ? nil : hsh
  end

  included do
    class << self
      def demongoize(args)
        new.from_hash(args)
      end
      alias_method :from_cache, :demongoize
      alias_method :from_hash, :demongoize

      def mongoize(object)
        object.is_a?(Hash) ? object : object.to_hash
      end

      def evolve(object)
        object.mongoize
      end
    end
  end
end
