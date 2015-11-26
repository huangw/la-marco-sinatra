require 'spec_helper'
require 'core_ext/string_simple_format'

describe String do
  describe '#to_text_field' do
    it 'to_text_field, to_simple_format will change string' do
      str1 = " <a>123\r\n456</a>"
      str2 = " <a>123\r\n456</a>"
      str3 = " <a>123\r\n456</a>"

      str1.to_simple_format
      str2.to_text_field

      expect(str1).to eq(str2)
      expect(str1).to eq("<a>123\n456</a>")
      expect(str1).to_not eq(str3)
    end
  end

  describe '#to_simple_format' do
    it 'convert new line to br, two new line as new paragraph' do
      expect("paragraph1\n\nparagraphs2\nnew line\n\n".to_simple_format).to eq('<p>paragraph1<br /><br />paragraphs2<br />new line</p>')
    end

    it 'will escape the html format' do
      expect("<a>123\r\n456</a>".to_simple_format).to eq("<p>&lt;a&gt;123<br />456&lt;&#x2F;a&gt;</p>")
    end
  end
end
