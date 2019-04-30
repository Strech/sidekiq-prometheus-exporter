# frozen_string_literal: true

require 'erb'
require 'time'

# Exporter for the https://github.com/moove-it/sidekiq-scheduler
module Sidekiq
  module Prometheus
    module Exporter
      class Scheduler
        TEMPLATE = ERB.new(File.read(File.expand_path('templates/scheduler.erb', __dir__)))
        SECONDS_IN_MINUTE = 60
        Stats = Struct.new(:jobs_count, :enabled_jobs_count, :last_runs)

        def self.available?
          defined?(Sidekiq::Scheduler)
        end

        def initialize
          @stats = Stats.new(recurring_jobs.count, enabled_recurring_jobs.count, last_runs)
        end

        def to_s
          TEMPLATE.result(binding).chomp!
        end

        private

        def last_runs
          enabled_recurring_jobs.each_with_object({}) do |name, memo|
            execution_time = SidekiqScheduler::RedisManager.get_job_last_time(name)
            next unless execution_time

            memo[name] = (Time.now.to_i - Time.parse(execution_time).to_i) / SECONDS_IN_MINUTE
          end
        end

        def enabled_recurring_jobs
          recurring_jobs.select { |name| Sidekiq::Scheduler.job_enabled?(name) }
        end

        def recurring_jobs
          @recurring_jobs ||= (Sidekiq.schedule! || {}).keys.sort
        end
      end
    end
  end
end
