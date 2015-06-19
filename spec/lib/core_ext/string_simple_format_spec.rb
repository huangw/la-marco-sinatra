require 'spec_helper'
require 'core_ext/string_simple_format'

describe String do
  describe '#to_simple_format' do
    it 'convert new line to br, two new line as new paragraph' do
      expect("paragraph1\n\nparagraphs2\nnew line\n\n".to_simple_format).to eq('<p>paragraph1</p><p>paragraphs2<br />new line</p>')
    end
  end
end
