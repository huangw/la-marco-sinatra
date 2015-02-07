# [Controller] '/api/hello_doc_api'
#   (app/pages/api/hello_doc_api.rb)
# vim: foldlevel=2
# created at: 2015-02-07

# API controller for '/api/hello_doc_api'
module API
  class HelloDocAPI < RestfulAPI
    get '/' do
      { hello: 'world' }
    end

    Route << self
  end
end
