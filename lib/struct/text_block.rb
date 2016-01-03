# [Class] TextBlock (lib/struct/text_block.rb)
# vim: foldlevel=1
# created at: 2015-01-30
require 'sanitize'

# Class for a paragraph of plain text with `type` (style)
class TextBlock
  include HashStruct

  TYPES = %w(P CP RP H3 H4 H5 UL OL CL HR)

  def self.types_hash
    TYPES.each_with_object({}) { |a, rslt| rslt[a] = self }
  end

  def struct
    { tid: nil, _type: 'P', text: '' }
  end
  # alias_method :to_cache, :to_hash

  def header?
    %w(H2 H3 H4 H5).include?(_type)
  end

  def convert_text=(str)
    Sanitize.fragment(str, Sanitize::Config::BASIC)
  end
end
