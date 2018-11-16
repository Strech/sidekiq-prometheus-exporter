# frozen_string_literal: true

require 'sidekiq/api'

module Sidekiq
  module Prometheus
    class Metrics
      QueueStats = Struct.new(:name, :size, :latency)

      def initialize
        @overview_stats = Sidekiq::Stats.new
        @queues_stats = queues_stats
        @max_processing_times = max_processing_times
      end

      def __binding__
        binding
      end

      private

      def queues_stats
        Sidekiq::Queue.all.map do |queue|
          QueueStats.new(queue.name, queue.size, queue.latency)
        end
      end

      def max_processing_times
        now = Time.now.to_i
        works_per_queue = Sidekiq::Workers.new.map { |_, _, work| work }.group_by { |work| work['queue'] }
        oldest_work_per_queue = works_per_queue.map do |queue, works|
          oldest_work = works.min_by { |work| work['run_at'] }
          [queue, now - oldest_work['run_at']]
        end
        oldest_work_per_queue.to_h
      end
    end
  end
end
