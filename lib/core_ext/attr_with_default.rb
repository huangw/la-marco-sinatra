# encoding: utf-8

# mixin normal class
class Class
  def attr_with_default(hsh)
    hsh.each do |k, v|
      send(:define_method, k.to_sym) do
        instance_variable_set("@#{k}", v) unless instance_variable_get("@#{k}")
        instance_variable_get("@#{k}")
      end
    end
  end
end
