# for slim helper test
module Slimmer
  # for slim helper path test
  class TranslatorPage < WebApplication
    get '/' do
      rsp
    end

    get '/hello' do
      rsp
    end

    Route << self
  end
end
