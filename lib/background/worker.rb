# [Class] Worker (lib/background/worker.rb)
# vim: foldlevel=1
# created at: 2015-09-07

# Namespece for background job related modules
module Background
  # Background job worker with state management
  class Worker
    attr_reader :name

    def initialize(klass, opts = {})
      @klass = klass
      @name = "#{opts[:name] || 'Worker'} (#{@klass})"
      @logger = opts[:logger] || GlobalLogger.instance
      @interval = opts[:interval] || 1 # sleep interval if no job waiting
      @start_at = nil
      @stopped_at = nil
      @terminated = false
    end

    def start_loop
      @started_at = Time.now
      @stopped_at = nil
      loop do
        break if @terminating
        sleep @interval unless @klass.perform(@name, @logger)
      end

      @terminating = false
      @stopped_at = Time.now
    end

    def stop_loop!
      @terminating = true
    end

    def terminated?
      state == :terminated
    end

    def state
      return :terminated if @stopped_at
      return :terminating if @terminating
      return :running if @started_at
      :waiting
    end
  end # Worker
end
