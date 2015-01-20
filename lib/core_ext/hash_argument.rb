# encoding: utf-8
require 'active_support/core_ext/hash/keys'

# Mixin hash class, add methods to extract argument value from a hash
class Hash
  # Extract and delete all `expects.keys` with default value `expects.values`
  def extract_args(expects)
    symbolize_keys! # convert all keys to symbol (more like arguments)

    # standardize expect to symbol key hash format:
    expects = Hash[expects.map { |k| [k.to_sym, nil] }] if expects.is_a?(Array)
    expects = expects.to_sym if expects.is_a?(String)
    expects = { expects => nil } if expects.is_a?(Symbol)
    expects.symbolize_keys!

    # map self, delete value or use the default, return a hash
    lst = expects.map { |k, v| key?(k.to_sym) ? delete(k.to_sym) : v }

    # return a scalar format if the there is only one value
    lst.size > 1 ? lst : lst.first
  end

  # Extract and delete all `hsh.keys` with default value `hsh.values`,
  # raise error if undefined keys contains in `hsh`.
  def extract_args!(expects)
    vars = extract_args(expects)
    fail "Unknown arguments: #{keys.join ','}" if keys.size > 0
    vars
  end
end
