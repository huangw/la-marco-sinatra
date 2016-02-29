# [Class] LaBufferedLogger (lib/la_buffered_logger.rb)
# vim: foldlevel=1
# created at: 2015-01-31
require 'logger'
require 'utils/la_backtrace_cleaner'

# A logger buffers messages until threshold number reached or flush!
# method explicitly called.
class LaBufferedLogger
  include ::Logger::Severity

  LEVELS = [:debug, :info, :warn, :error, :fatal, :unknown].freeze # 0 .. 5

  attr_accessor :flush_threshold, :request_info
  attr_reader :level, :msgs

  def initialize(opts = {})
    self.level = opts.extract_args!(level: :debug)
    @request_info = {}
    @msgs = []
    @access_recorded = false
    @logger = global_logger
  end

  def flush!
    @msgs.each { |msg| @logger.send msg['severity'], msg }
    @msgs = []
  end

  def access_recorded?
    @access_recorded ? true : false
  end

  # Accept both LaLogger::ERROR (which is actually an integer), or
  # symbols like :warn, :error, ...
  def level=(lvl)
    @level = lvl.is_a?(Integer) ? LEVELS[lvl] : lvl.to_s.downcase.to_sym
    raise "Unknown level #{lvl}" unless LEVELS.include?(@level)
    @level
  end

  def event(type, dat = {})
    append dat.merge(event: type)
  end

  def append(dat)
    request_info['severity'] ||= 'warn'
    @msgs << request_info.merge(dat)
  end

  LEVELS.each_with_index do |met, lvl|
    define_method(met) do |message, opts = {}|
      return nil if lvl < LEVELS.index(level.to_sym) # skip if lower level set
      dat = opts.merge 'severity' => met.to_s # , 'c_at' => Time.now

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

  def access
    info '-'
    @access_recorded = true
  end
end
