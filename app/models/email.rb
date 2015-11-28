require 'email_render'

# Email name space
module Emails
  # email base model
  class Email
    include Mongoid::Document
    include HashPresenter
    include EmailRender

    def to_hash
      _to_hash [:to]
    end
  end
end
