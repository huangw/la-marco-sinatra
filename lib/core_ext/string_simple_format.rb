# [Class] StringSimpleFormat (lib/core_ext/string_simple_format.rb)
# vim: foldlevel=1
# created at: 2015-06-18

# convert newline to <br />, two newlines to separate <p></p>
class String
  def to_simple_format
    txt = dup.sub(/\A\s*/, '').sub(/\s*\Z/, '')
    txt.gsub!(/\s*\n\n\s*/, '</p><p>')
    '<p>' << txt.gsub(/\s*\n\s*/, '<br />') << '</p>'
  end
end
