# [Model] MockEmail
# (app/models/emails/mock_email.rb)
# vim: foldlevel=2
# created at: 2015-12-02

# mixin Emails namespace
module Emails
  # Email for MockEmail
  class MockEmail < Email
    def to_hash
      super
    end
  end
end
