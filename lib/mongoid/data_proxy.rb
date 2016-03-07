# [Class] DataProxy
#   (lib/mongoid/data_proxy.rb)
# vi: foldlevel=1
# created at: 2016-02-25
require 'active_support/concern'
require 'utils/hash_serialize'

# A hash struct that caches an other object (a model instance, etc.)
# as the master data.
module DataProxy
  extend ActiveSupport::Concern
  attr_accessor :_mt, :sid, :_e_at # master class

  def initialize(master_data = nil, e_for = nil)
    _from_hash _struct # initialize default values of local struct

    if master_data.is_a?(DataProxy) || master_data.is_a?(Hash)
      merge master_data, e_for
    elsif master_data
      refresh! master_data, e_for
    end
  end

  # rubocop:disable MethodLength
  def refresh!(master_data = nil, e_for = nil)
    master_data ||= master!
    if master_data.respond_to?(:to_proxy)
      _from_hash master_data.to_proxy([_proxy])
    else
      master_data.extend(HashSerialize) unless master_data.is_a?(HashSerialize)
      _from_hash master_data._to_hash([_proxy])
    end

    self._mt ||= master_data.class.to_s
    self.sid ||= master_data.sid
    expire_for! e_for
    self
  end

  def expire_for!(e_for = nil)
    e_for ||= _cache_for
    # if no _cache_for, and no e_for specified, do not cache at all
    self._e_at ||= (Time.now + e_for).short if e_for
  end

  def expired?
    exp_at = expire_at # only calculate `expire_at` once
    exp_at && exp_at < Time.now
  end

  def expire_at
    # if `_e_at` is not set, never expires
    _e_at && Time.from_short(_e_at)
  end

  def master!
    master_class.s_find(sid)
  end

  def master_class
    Object.const_get(_mt) unless _mt.blank?
  end

  def _type
    self.class.to_s
  end

  def _type=(_)
  end

  def to_hash_keys
    (_proxy.keys + _struct.keys + [:_mt, :sid, :_e_at]).uniq
  end

  def to_hash
    hsh = _to_hash to_hash_keys
    yield hsh if block_given?
    hsh['_type'] = _type # Always use self.class as _type
    hsh
  end

  # Merge keys from a hash or an other Proxy
  def merge(hsh, e_for = nil)
    hsh = hsh.to_hash unless hsh.is_a?(Hash)
    slice = {}
    hsh.symbolize_keys.each do |k, v|
      slice[k] = v if to_hash_keys.include?(k.to_sym)
    end

    _from_hash slice
    expire_for! e_for
    slice
  end

  included do
    include HashSerialize
    class << self
      # rubocop:disable CyclomaticComplexity
      def proxy(hash_keys, opts = {})
        # Set up proxy methods for the Master Data
        ksh = hash_keys.reduce({}) do |hsh, k|
          hsh.merge k.is_a?(Hash) ? k : { k => k.to_sym }
        end.symbolize_keys
        super_instance = superclass.new if superclass < DataProxy
        ksh = super_instance._proxy.merge(ksh) if super_instance
        send(:define_method, :_proxy) { ksh }

        # Set local accessors not from Master but only inside the current object
        st = opts[:struct] || {}
        st = super_instance._struct.merge(st) if super_instance
        send(:define_method, :_struct) { st.symbolize_keys }

        default_cache_for = DataProxySettings.default_cache_for
        default_cache_for = super_instance._cache_for if super_instance
        cf = opts.key?(:cache_for) ? opts[:cache_for] : default_cache_for
        send(:define_method, :_cache_for) { cf }

        (ksh.keys + st.keys).each { |k| attr_accessor k }
      end

      def from_hash(hsh)
        pxy = new._from_hash(hsh)
        pxy.refresh! if pxy.expired?
        pxy
      end
    end
  end
end
