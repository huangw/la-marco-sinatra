require 'active_support/backtrace_cleaner'

# cleanup error back-trace by default filter set
module LaBacktraceCleaner
  # cleanup error back-trace from exception `e`
  def self.clean(e)
    @bc ||= ActiveSupport::BacktraceCleaner.new
    @bc.add_filter   { |line| line.gsub(ENV['APP_ROOT'], '') }
    @bc.add_silencer { |line| line =~ /ruby|gems/ }
    e.backtrace ? @bc.clean(e.backtrace) : []
  end
end
