# Safe parse any string without raise
class Date
  def self.safe_parse(value, default = nil)
    Date.parse(value.to_s)
  rescue ArgumentError
    default
  end
end
