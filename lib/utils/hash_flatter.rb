# Flatter nested hash to single dimensional one
module HashFlatter
  # Convert `{a: {b: {c: 1}}}` to `[:a, :b, :c] => 1`
  def hash_flat(hsh, k = [])
    return { k => hsh } unless hsh.is_a?(Hash)
    hsh.reduce({}) { |a, e| a.merge! hash_flat(e[-1], k + [e[0]]) }
  end

  # Convert `{a: {b: {c: 1}}}` to `'a.b.c' => 1`.
  # If specify `g = ':'`, convert to `'a:b:c' => 1`.
  def hash_join(hsh, g = '.')
    hash_flat(hsh).reduce({}) { |a, e| a.merge! e[0].join(g) => e[1] }
  end

  # hash_nest([:a, :b, :c], 18) => { a: { b: { c: 18 } } }
  def hash_nest(keys, value)
    keys.reverse.inject(value) { |a, e| { e => a } }
  end
end
