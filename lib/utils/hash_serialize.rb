# [Class] HashSerialize
#   (lib/core_ext/hash_serialize.rb)
# vi: foldlevel=1
# created at: 2016-02-22

# All general ruby object to be serialize to and deserialize
# from hash presenters based on template and options
module HashSerialize
  DEFAULT_TYPE_CONV = { Time => :to_f, DateTime => :to_f, Date => :to_i }.freeze
  TO_HASH_OPTS = { include_nil: false, default_converter: :to_hash,
                   convert_keys: :string }.freeze

  # `keys` (Array) defines which keys to exposed to the result hash:
  #
  # [:id, :name, ...]
  #
  # if element in the present array is a hash, like
  #   `[{object_id: :_id}, :other_staff]`
  #
  # `object_id` will be the key of the hash and `#_id` method
  # will be called for the value.
  #
  # use `->` for instant procedure:
  #   `[ { object_id: -> { _id.to_s } } ]`
  #
  # `opts` defines the follow options:
  # - include_nil: include keys with nil value, default be false
  # - default_converter: convert method for all type not defined in `type_hash`
  # - string_keys: default is true, convert all keys to string
  # - symbol_keys: default is false, convert all keys to symble
  # - type_conv: Time object will convert to Float, Date to Int, ...
  #
  # rubocop:disable CyclomaticComplexity, MethodLength
  def _to_hash(keys, opts = {})
    opts = TO_HASH_OPTS.merge opts
    opts[:type_conv] ||= DEFAULT_TYPE_CONV
    raise 'string_keys and symbol_keys can not both be '\
         'true' if opts[:string_keys] && opts[:symbol_keys]

    hsh = {}
    _keys_to_hash(keys).each do |k, v|
      v = send(v) if v.is_a?(Symbol)
      v = v.call if v.is_a?(Proc)

      v = convert_val(v, opts[:type_conv], opts[:default_converter])

      k = k.to_s if opts[:convert_keys] == :string
      k = k.to_sym if opts[:convert_keys] == :symbol
      next if v.nil? && !opts[:include_nil]
      hsh[k] = v
    end

    yield hsh if block_given?
    hsh
  end

  # Recursively restore object from hash, ignore not defined keys
  # Define a empty `key=` method to discard unneeded value in `hsh`
  def _from_hash(hsh)
    hsh.each do |k, v|
      if v.is_a?(Hash) && v['_type']
        klass = Object.const_get(v['_type'].to_s.classify)
        # recursively de-serialize by .from_hash method
        v = klass.from_hash(v) if klass.respond_to?(:from_hash)
      end

      send(:"#{k}=", v)
    end
    self
  end

  private

  # Convert array presenters to hash `:key => :method` hash
  def _keys_to_hash(keys)
    keys.reduce({}) do |hsh, k|
      hsh.merge k.is_a?(Hash) ? k.symbolize_keys : { k.to_sym => k.to_sym }
    end
  end

  def convert_val(v, type_h, dmet)
    if type_h[v.class] # convert type
      v.send(type_h[v.class])
    elsif dmet && v.respond_to?(dmet)
      v.send(dmet)
    else
      v
    end
  end
end
