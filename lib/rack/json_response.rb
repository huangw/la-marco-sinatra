# [Class] JsonResponse (lib/rack/json_response.rb)
# vim: foldlevel=1
# created at: 2015-01-31
require 'multi_json'

# Namespace for Rack middlewares
module Rack
  # Class for Json response handler
  class JsonResponse
    def initialize(app)
      @app = app
    end

    # rubocop:disable LineLength, MethodLength, CyclomaticComplexity
    def call(env)
      # setup environment, initialize common response
      env['response_hash'] = {}

      begin
        status, headers, body = @app.call(env)
        body = body.to_hash unless body.is_a?(Hash) # and !body.respond_to?(:to_hash)

        # merge the common response hash
        jbody = MultiJson.encode(env['response_hash'].merge body)
      rescue => e
        status = e.respond_to?(:status) ? e.status : 500
        headers ||= {}
        body = { 'error' => e.class.name.underscore, 'message' => e.message }
        i18n_msg = e.i18n_message if e.respond_to?(:i18n_message)
        if i18n_msg
          body['i18n_message'] = i18n_msg unless i18n_msg.match(/\Atranslation missing:/)
        end

        # Do not include back trace for production or documentation
        body['backtrace'] = LaBacktraceCleaner.clean(e) unless ENV['RACK_ENV'] == 'production' || ENV['DOC']
        jbody = MultiJson.encode(body)
      end

      # merge the body to hash
      headers['Content-Type'] = 'application/json; charset=UTF-8'
      # headers['Content-Length'] = jbody.size.to_s
      [status, headers, [jbody]]
    end
  end
end
