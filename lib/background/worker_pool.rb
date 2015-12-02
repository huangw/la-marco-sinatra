# [Class] WorkerPool (lib/background/worker_pool.rb)
# vim: foldlevel=1
# created at: 2015-09-07
require_relative 'worker'
require 'fileutils'

# Namespece for background job related modules
module Background
  # Manger for multi-workers
  class WorkerPool
    def initialize(opts = {})
      # sleep for interval seconds
      @worker_interval = opts[:worker_interval] || 1

      # restore to waiting status if process takes too long seconds to complete
      @restore_interval = opts[:restore_interval] || 180

      # store current process id in pid file
      @pid_file = opts[:pid_file] || root_join('tmp/bj_worker.pid')

      # worker definitions in hash: Class => number of workers in the cluster
      @workers = opts[:workers] || {}
      @_workers = [] # this is the actual pool for all started workers
      @threads = [] # the threads workers running under
    end

    def start!
      set_trap
      puts "[#{Time.now.strftime('%F %T')}] Starting workers: "
      @workers.each { |klass, num| start_workers(klass, num) }
      File.open(@pid_file, 'wb') { |wh| wh.write Process.pid } if @pid_file
      puts "Starting main loop for #{ENV['RACK_ENV']} (#{Process.pid}). "\
           'Using Ctrl-C to exist.'
      main_loop
    end

    def stop
      @_workers.each(&:'stop_loop!')
      print "Waiting all #{@_workers.size} workers to stop ... "
      loop do
        break if all_worker_stopped?
        sleep 0.1
      end
      @threads.each(&:kill)
      puts 'STOPPED'
    end

    def stop!
      stop
      FileUtils.rm_rf @pid_file if @pid_file && File.exist?(@pid_file)
      exit
    end

    def start_workers(klass, num)
      num.times do |i|
        worker = Worker.new(klass, interval: @worker_interval,
                                   name: "Worker #{i + 1}")
        print " - Starting #{worker.name} ... "
        sleep @worker_interval.to_f / num if i > 0
        @threads << Thread.new { worker.start_loop }
        puts 'OK'
        @_workers << worker
      end
    end

    def all_worker_stopped?
      @_workers.each { |w| return false unless w.terminated? }
      true
    end

    def set_trap
      Signal.trap(:INT) { stop! }
      # Signal.trap(:TERM) { stop! }
    end

    def main_loop
      loop do
        sleep @restore_interval
        # revert jobs processed for too long time (worker dead?)
        @workers.keys.each do |klass|
          klass.where(job_state: 100)
            .lt(u_at: Time.now - @restore_interval).each do |job|
            job.update_attribute state: 10 # switch back to waiting
          end
        end # each work class
      end # loop
    end # main loop
  end # WorkerPool
end
