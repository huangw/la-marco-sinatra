# mixin Time class, add short version timestamp
class Time
  EPOCH = 1_400_000_000 # 2014-05-14 00:53:20 +0800
  def short
    (to_i - EPOCH).to_s(36)
  end

  def hex
    (to_i - EPOCH).to_s(16)
  end

  def self.from_short(sstr)
    at(sstr.to_i(36) + EPOCH)
  end

  def self.from_hex(hstr)
    at(hstr.to_i(16) + EPOCH)
  end
end
