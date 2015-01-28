# Mixin String class, return common parts from the begin of the string
class String
  def common_head(str)
    return nil unless str.is_a?(String)
    common_part = ''
    (0..length - 1).each do |i|
      return common_part unless str[i] == self[i]
      common_part << self[i]
    end
    common_part
  end
end
