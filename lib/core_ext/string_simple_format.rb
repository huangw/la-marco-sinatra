# [Class] StringSimpleFormat (lib/core_ext/string_simple_format.rb)
# vim: foldlevel=1
# created at: 2015-06-18
require 'sanitize'

# convert newline to <br />, two newlines to separate <p></p>
class String
  def to_simple_format
    to_text_field
    # txt = dup.sub(/\A\s*/, '').sub(/\s*\Z/, '').gsub(/\\r/, '')
    # txt.gsub!(/\s*\n\n\s*/, '</p><p>')
    txt = Rack::Utils.escape_html(dup)

    '<p>' << txt.gsub(/\n/, '<br />') << '</p>'
  end

  def to_text_field
    sub!(/\A\s*/, '').sub!(/\s*\Z/, '').gsub!(/\r/, '')
  end

  def filter_tag
    Sanitize.fragment(self, :elements=> ['a', 'b', 's', 'i', 'code', 'li'])
  end
end
