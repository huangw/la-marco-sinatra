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
        body = body.to_hash if !body.is_a?(Hash) && body.respond_to?(:to_hash)

        # merge the common response hash
        jbody = MultiJson.encode(env['response_hash'].merge(body))
      rescue => e
        status = e.respond_to?(:status) ? e.status : 500
        headers ||= {}

        if e.is_a?(RequestError) || e.is_a?(ServerError)
          body = { error: e.class.name.underscore, message: e.message }
        elsif e.is_a?(Mongoid::Errors::Validations)
          body = { error: e.class.name.underscore, messages: e.document.errors.messages }
        elsif status < 500 && status >= 400
          body = { error: e.class.name.underscore, message: I18n.t('exceptions.ajax.options_error') }
        else
          body = { error: e.class.name.underscore, message: I18n.t('exceptions.ajax.server_error') }
        end

        i18n_msg = e.i18n_message if e.respond_to?(:i18n_message)
        if i18n_msg
          body['i18n_message'] = i18n_msg unless i18n_msg.start_with?('translation missing:')
        end

        # Do not include back trace for production or documentation
        body['backtrace'] = LaBacktraceCleaner.clean(e) unless ENV['RACK_ENV'] == 'production' || ENV['DOC']
        jbody = MultiJson.encode(body)
        env['rack.logger'] && env['rack.logger'].fatal(e)
      end

      # merge the body to hash
      headers['Content-Type'] = 'application/json; charset=UTF-8'
      # headers['Content-Length'] = jbody.size.to_s
      [status, headers, [jbody]]
    end
  end
end
