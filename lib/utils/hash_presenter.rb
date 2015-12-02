# [Class] HashPresenter (lib/utils/hash_presenter.rb)
# vim: foldlevel=1
# created at: 2015-05-08

# Generate a hash from any object based on predefined keys
module HashPresenter
  DEFAULT_TYPE_H = { Time => :to_f, DateTime => :to_f, Date => :to_i }
  DEFAULT_OPTS = { include_nil: false, default_converter: :to_hash,
                   convert_keys: :string }
  # `keys` defines which keys to exposed to the present hash
  #
  # you can define presenters in varies formats:
  #
  # - hash with named style:
  #   `{ default: [:_id], detail: [:_id, :other_staffs] }`
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
  # - Keys are always converted to string format.
  # - Nil value will not be exposed.
  # - Time value will be convert to Integer.
  #
  # `type_h` defines convert methods for each data type (ruby class)
  #
  # `opts` defines the following properties:
  #
  # - include_nil: include keys with nil value, default be false
  # - default_converter: convert method for all type not defined in `type_hash`
  # - string_keys: default is true, convert all keys to string
  # - symbol_keys: default is false, convert all keys to symble
  #
  # rubocop:disable CyclomaticComplexity, MethodLength
  def _to_hash(keys, type_h = {}, opts = {})
    hsh = {}
    type_h = DEFAULT_TYPE_H.merge type_h
    opts = DEFAULT_OPTS.merge opts

    fail 'string_keys and symbol_keys can not both be '\
         'true' if opts[:string_keys] && opts[:symbol_keys]

    _keys_to_hash(keys).each do |k, v|
      v = send(v) if v.is_a?(Symbol)
      v = v.call if v.is_a?(Proc)

      if type_h[v.class] # convert type
        v = v.send(type_h[v.class])
      else
        dmet = opts[:default_converter]
        v = v.send(dmet) if dmet && v.respond_to?(dmet)
      end

      k = k.to_s if opts[:convert_keys] == :string
      k = k.to_sym if opts[:convert_keys] == :symbol
      next if v.nil? && !opts[:include_nil]
      hsh[k] = v
    end

    yield hsh if block_given?
    hsh
  end

  # Convert array presenters to hash `:key => :method` hash
  def _keys_to_hash(keys)
    keys.reduce({}) do |hsh, k|
      hsh.merge k.is_a?(Hash) ? k.symbolize_keys : { k.to_sym => k.to_sym }
    end
  end
end
