# [Class] Job (lib/background/job.rb)
# vim: foldlevel=1
# created at: 2015-09-07
require 'active_support/concern'

# Namespece for background job related modules
module Background
  # Background job with retry and delay
  module Job
    extend ActiveSupport::Concern

    included do
      include Mongoid::Timestamps::Short

      # nil => not a background job; 1 => error; 10 => complete;
      # 100 => processing; 300 => waiting
      field :_j_s, as: :job_state, type: Integer,
                   default: -> { default_job_state }

      # not perform until the specified time reached
      field :n_b, as: :not_before, type: Time
      field :tryouts, type: Array, default: []
      index _j_s: 1, n_b: -1

      def default_job_state
        300
      end

      scope :waiting, -> { where(job_state: 300) }

      # Number that has retried, count from tryouts
      def retried
        tryouts.size
      end

      # Max retry default for 5 times, override this in subclasses
      def max_retry
        5
      end

      # delay default for 30 seconds for retry, override this in subclasses
      def retry_delay
        30
      end

      # If tryout number equals or larger that max retry number
      def no_more_retry?
        retried >= max_retry
      end

      # rubocop:disable MethodLength
      def self.perform(worker = 'anonymous worker', logger = nil)
        logger ||= global_logger
        job = waiting.asc(:not_before)
              .any_of({ :not_before.lte => Time.now }, not_before: nil)
              .find_one_and_update({ '$set' => { _j_s: 100 } },
                                   return_document: :after)

        return nil unless job # No job is waiting
        warn "JOB STATUS ------------> #{job.job_state}"
        begin
          logger.info "[BJ #{worker}] (#{job.class}: #{job._id})"
          job.process!
          job.job_state = 10
        rescue => e
          logger.error "[BJ #{worker}] [#{e.class}] #{e.message}"\
                       " (#{job.class}: #{job._id})"

          job.tryouts << "[#{e.class}] #{e.message}"

          if job.no_more_retry?
            job.job_state = 1 # indicate an error, stop retry
          else
            job.job_state = 300
            job.not_before ||= Time.now
            job.not_before = job.not_before + job.retry_delay
          end
        end

        job.save && job
      end
    end # included
  end # SimpleJob
end # Background
