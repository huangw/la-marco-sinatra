# [Class] StringSimpleFormat
#   (lib/core_ext/string_simple_format.rb)
# vi: foldlevel=1
# created at: 2016-02-23

# Port from active view `simple_format` method
class String
  # convert string to HTML using simple formatting rules.
  # Two or more consecutive newlines(<tt>\n\n</tt>) are considered as a
  # paragraph and wrapped in <tt><p></tt> tags. One newline (<tt>\n</tt>) is
  # considered as a linebreak and a <tt><br /></tt> tag is appended. This
  # method does not remove the newlines from the +text+.
  def simple_format
    paragraphs = split_paragraphs

    if paragraphs.empty?
      '<p></p>'
    else
      paragraphs.map! do |paragraph|
        "<p>#{paragraph}</p>"
      end.join("\n\n")
    end
  end

  def split_paragraphs
    text = dup
    return [] if text.blank?

    text.to_s.gsub(/\r\n?/, "\n").split(/\n\n+/).map! do |t|
      t.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') || t
    end
  end
end
