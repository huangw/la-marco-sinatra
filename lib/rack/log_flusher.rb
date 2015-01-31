# Namespace for rack middlewares
module Rack
  # Write out event logger (only need for web application)
  class LogFlusher
    def initialize(app, opts = {})
      @app, @opts = app, opts
    end

    # rubocop:disable MethodLength, LineLength
    def call(env)
      t1 = Time.now
      logger_klass = @opts.delete(:logger) || LaBufferedLogger
      env['rack.logger'] = logger_klass.new @opts

      req = Rack::Request.new env
      { ip: :ip, met: :request_method, path: :path, ua: :user_agent, rf: :referer }.each do |k, met|
        env['rack.logger'].request_info[k] = req.send(met) if req.send(met)
      end

      begin
        status, headers, body = @app.call(env)
        env['rack.logger'].request_info['status'] = status
        env['rack.logger'].request_info['tm'] = Time.now - t1
      rescue => e
        env['rack.logger'].fatal(e)
      end

      env['rack.logger'].flush! if env['rack.logger'].respond_to?(:'flush!')
      [status, headers, body]
    end
  end
end
