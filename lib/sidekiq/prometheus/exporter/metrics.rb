# frozen_string_literal: true

require 'sidekiq/api'

module Sidekiq
  module Prometheus
    class Metrics
      QueueStats = Struct.new(:name, :size, :latency)

      def initialize
        @overview_stats = Sidekiq::Stats.new
        @cron_stats = cron_stats
        @queues_stats = queues_stats
        @max_processing_times = max_processing_times
      end

      def __binding__
        binding
      end

      private

      def cron_stats
        return {enabled: false} unless defined?(::Sidekiq::Cron::Job)
        {
          enabled: true,
          count: ::Sidekiq::Cron::Job.all.count
        }
      end

      def queues_stats
        Sidekiq::Queue.all.map do |queue|
          QueueStats.new(queue.name, queue.size, queue.latency)
        end
      end

      def max_processing_times
        now = Time.now.to_i
        Sidekiq::Workers.new
          .map { |_, _, execution| execution }
          .group_by { |execution| execution['queue'] }
          .each_with_object({}) do |(queue, executions), memo|
            oldest_execution = executions.min_by { |execution| execution['run_at'] }
            memo[queue] = now - oldest_execution['run_at']
          end
      end
    end
  end
end
