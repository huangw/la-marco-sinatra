# [Class] SimpleJob (lib/background/simple_job.rb)
# vim: foldlevel=1
# created at: 2015-09-07
require 'active_support/concern'

# Namespece for background job related modules
module Background
  # Background job without retry
  module SimpleJob
    extend ActiveSupport::Concern

    included do
      include Mongoid::Timestamps::Short

      # nil => not a background job; 1 => error; 10 => complete;
      # 100 => processing; 300 => waiting
      field :_j_s, as: :job_state, type: Integer,
                   default: -> { default_job_state }

      def default_job_state
        300
      end

      scope :waiting, -> { where(job_state: 300) }

      # rubocop:disable MethodLength
      def self.perform(worker = 'anonymous worker', logger = nil)
        logger ||= global_logger
        job = waiting.asc(:c_at)
              .find_one_and_update({ '$set' => { _j_s: 100 } },
                                   return_document: :after)

        return nil unless job # No job is waiting

        begin
          logger.info "[BJ #{worker}] #{job.class} (#{job._id})"
          job.process!
          job.job_state = 10
        rescue => e
          logger.error "[BJ #{worker}] [#{e.class}] #{e.message}"\
                       " (#{job._id})"
          job.job_state = 1
        end

        job.save && job
      end
    end # included
  end # SimpleJob
end # Background
