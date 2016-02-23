# [Controller] '/api/hello_doc_api'
#   (app/pages/api/hello_doc_api.rb)
# vim: foldlevel=2
# created at: 2015-02-07

module API
  # API controller for '/api/hello/docs'
  class HelloDocAPI < RestfulController
    get '/' do
      { hello: 'world' }
    end

    Route << self
  end
end
