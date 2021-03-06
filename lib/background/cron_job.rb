# [Class] CronJob (lib/background/cron_job.rb)
# vim: foldlevel=1
# created at: 2015-10-21

require 'active_support/concern'

# Namespece for background job related modules
module Background
  # Background job processing for a specified interval
  module CronJob
    extend ActiveSupport::Concern

    included do
      field :_j_at, as: :job_started_at, type: Time
      field :n_b, as: :not_before, type: Time
      index _j_at: 1, n_b: -1

      # rubocop:disable MethodLength, LineLength
      def self.perform(worker = 'anonymous worker', logger = nil)
        logger ||= GlobalLogger.instance
        job = where(_j_at: nil).asc(:not_before)
                               .any_of({ :not_before.lte => Time.now }, not_before: nil)
                               .find_one_and_update({ '$set' => { _j_at: Time.now } }, return_document: :after)

        return nil unless job # No job is waiting

        begin
          t1 = Time.now
          job.process!
        rescue => e
          logger.error "[Cron #{worker}] [#{e.class}] #{e.message}"\
                       " (#{job._id})"
        end

        logger.info format('[Cron %s] %s %.02f',
                           worker, self.class, Time.now - t1)

        job.not_before = job.next_time # to next round even process failed
        job._j_at = nil
        job.save && job
      end
    end
  end # CronJob
end
