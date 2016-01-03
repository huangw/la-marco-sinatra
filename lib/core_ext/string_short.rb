# [Class] String (lib/core_ext/string_short.rb)
# vim: foldlevel=1
# created at: 2015-06-18
require 'sanitize'

# Mixin String class, add method for shorten
class String
  def short(leng = 20)
    txt = Sanitize.fragment(self) # delete HTML tags
    return txt[0..leng - 1] if leng <= 5
    length <= leng ? txt : txt[0..leng - 5] + ' ...'
  end
end
