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
    node_tid = node.attributes['id'] && node.attributes['id'].value
    node_tid = nil if node_tid.blank? # default is ''
    bk = new(tid: node_tid, text: node.inner_html)
    klasses = node.attributes['class']
    klasses = klasses ? klasses.value.split(/\s+/) : []
    label = node.name.upcase
    if label == 'P'
      bk.label = if klasses.include?('cp')
                   'CP'
                 elsif klasses.include?('rp')
                   'RP'
                 else
                   'P'
                 end
    elsif %w(H3 H4 H5 HR).include?(label)
      bk.label = label
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
