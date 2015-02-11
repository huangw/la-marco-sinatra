require 'spec_helper'

describe '/api/hello-docs' do
  describe 'Hello world message [GET]' do
    it 'get the message properly' do
      expect(r('GET /api/hello/docs').hello).to eq('world')
    end
  end
end
