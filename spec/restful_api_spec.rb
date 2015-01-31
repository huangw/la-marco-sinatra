# encoding: utf-8
require 'spec_helper'

def app
  RestfulAPI.new
end

describe '/api/' do
  it 'returns valid json response' do
    expect(r('GET /')).to_not be_nil
    # puts last_response.body
    expect(r.hello).to eq('world')
    expect(s).to eq(200)
  end

  it 'catch exceptions' do
    expect(r('GET /error')).to_not be_nil
    expect(r.error).to eq('runtime_error')
    expect(sp).to eq(500)
    expect(r.message).to eq('can not avoid')
  end

  it 'catch 401 errors' do
    expect(r('GET /auth_error')).to_not be_nil
    expect(r.error).to eq('authentication_error')
    expect(sp).to eq(401)
    expect(r.message).to eq('returns 401')
  end

  it 'catch 404 errors' do
    expect(r('GET /not_here?locale=en')).to_not be_nil
    expect(sp).to eq(404)
    expect(r.message).to eq('not_found')
  end
end
