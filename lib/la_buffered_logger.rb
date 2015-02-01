# [Class] LaBufferedLogger (lib/la_buffered_logger.rb)
# vim: foldlevel=1
# created at: 2015-01-31
require 'logger'
require 'utils/la_backtrace_cleaner'
require 'celluloid/autostart'
Celluloid.logger = nil

# A logger buffers messages until threshold number reached or flush!
# method explicitly called.
class LaBufferedLogger
  include ::Logger::Severity
  include Celluloid

  LEVELS = [:debug, :info, :warn, :error, :fatal, :unknown] # 0 .. 5

  attr_accessor :flush_threshold, :request_info
  attr_reader :level, :msgs

  def initialize(opts = {})
    self.level = opts.extract_args!(level: :debug)
    @request_info, @msgs = {}, []
  end

  def flush!
    @msgs.each { |msg| ap msg }
    @msgs = []
  end

  # Accept both LaLogger::ERROR (which is actually an integer), or
  # symbols like :warn, :error, ...
  def level=(lvl)
    @level = lvl.is_a?(Integer) ? LEVELS[lvl] : lvl.to_s.downcase.to_sym
    fail "Unknown level #{lvl}" unless LEVELS.include?(@level)
    @level
  end

  def event(type, msg, opts = {})
    append opts.merge(type: type, message: msg.to_s)
  end

  def access(status, timespend, opts = {})
    append opts.merge(@request_info.merge(type: 'access', status: status.to_i,
                                          tm: timespend))
  end

  def append(dat)
    @msgs << dat
  end

  LEVELS.each_with_index do |met, lvl|
    define_method(met) do |message, opts = {}|
      return nil if lvl < LEVELS.index(level.to_sym) # skip if lower level set
      dat = opts.merge 'severity' => lvl, 'c_at' => Time.now

      if message.is_a?(Exception)
        dat['exception'] = message.class.to_s
        dat['message'] = message.message
        dat['backtrace'] = LaBacktraceCleaner.clean(message)
      else
        dat['message'] = message
      end

      append dat
      flush! if flush_threshold && @msgs.size > flush_threshold
      dat
    end
  end
end
