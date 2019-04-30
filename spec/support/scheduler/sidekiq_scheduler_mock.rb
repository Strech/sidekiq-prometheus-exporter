# frozen_string_literal: true

module SidekiqSchedulerMock
  module Sidekiq
    def self.schedule!
      raise NotImplementedError, 'please do not use this method without stub'
    end

    class Scheduler
      def self.job_enabled?(_name)
        raise NotImplementedError, 'please do not use this method without stub'
      end
    end
  end

  module RedisManager
    def self.get_job_last_time(_name)
      raise NotImplementedError, 'please do not use this method without stub'
    end
  end
end
