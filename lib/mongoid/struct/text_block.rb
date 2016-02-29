# [Class] TextBlock
#   (lib/mongoid/struct/text_block.rb)
# vi: foldlevel=1
# created at: 2016-02-23
require 'utils/hash_struct'

# Represent a text block on html document
class TextBlock
  include HashStruct

  LABELS = %w(P CP RP H3 H4 H5 HR).freeze
  struct tid: nil, text: '', label: 'P'

  def text=(str)
    @text = str.nil? ? str : Sanitize.fragment(str, Sanitize::Config::BASIC)
  end

  # rubocop:disable CyclomaticComplexity, MethodLength
  def to_html
    label.upcase!
    case label
    when 'P' then _to_html('p')
    when 'CP' then _to_html('p', 'cp')
    when 'RP' then _to_html('p', 'rp')
    when 'H3' then _to_html('h3')
    when 'H4' then _to_html('h4')
    when 'H5' then _to_html('h5')
    when 'HR' then '<hr />'
    else
      raise "unknown label #{label}"
    end
  end

  def self.from_html(node)
    bk = new(tid: node.tid, text: node.inner_html)
    node_name = node.name.upcase
    if node_name == 'P'
      bk.label = if node.class?('cp')
                   'CP'
                 elsif node.class?('rp')
                   'RP'
                 else
                   'P'
                 end
    elsif %w(H3 H4 H5 HR).include?(node_name)
      bk.label = node_name
    else
      raise "unknown label #{label}"
    end
    bk
  end

  private

  def _to_html(tag, klass = nil)
    klass = %( class="#{klass}") if klass
    %(<#{tag} id="#{tid}"#{klass}>#{text}</#{tag}>)
  end
end
