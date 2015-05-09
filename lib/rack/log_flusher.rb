# Namespace for rack middlewares
module Rack
  # Write out event logger (only need for web application)
  class LogFlusher
    def initialize(app, opts = {})
      @app = app
      @opts = opts
      @logger_klass = @opts.delete(:logger) || LaBufferedLogger
    end

    # rubocop:disable MethodLength, LineLength
    def call(env)
      @logger = env['rack.logger'] = @logger_klass.new @opts
      t1 = Time.now

      req = Rack::Request.new env
      { ip: :ip, met: :request_method, path: :path, ua: :user_agent, rf: :referer }.each do |k, met|
        @logger.request_info[k] = req.send(met) if req.send(met)
      end

      begin
        status, headers, body = @app.call(env)

        @logger.request_info['status'] = status
        @logger.request_info['tm'] = Time.now - t1
      rescue => e
        status = e.respond_to?(:status) ? e.status : 500
        @logger.fatal(e)
      end

      @logger.access(status, tm: Time.now - t1)
      # @logger.async.flush!
      @logger.flush!
      [status, headers, body]
    end
  end
end
