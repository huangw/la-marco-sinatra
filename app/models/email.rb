require 'emails/render'
require 'emails/fake_sender'
require 'emails/mailgun_sender'
require 'emails/aliyun_sender'

# Email name space
module Emails
  # email base model
  class Email
    include Mongoid::Document
    include HashPresenter
    include Emails::Render

    def to_hash
      _to_hash [:to, { model: -> { model_name.name } }]
    end
  end
end
