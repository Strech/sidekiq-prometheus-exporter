# frozen_string_literal: true

require 'erb'
require 'sidekiq/api'

module Sidekiq
  module Prometheus
    module Exporter
      class Standard
        TEMPLATE = ERB.new(File.read(File.expand_path('templates/standard.erb', __dir__)))

        QueueStats = Struct.new(:name, :size, :latency)
        QueueWorkersStats = Struct.new(:total_workers, :busy_workers, :processes)
        WorkersStats = Struct.new(:total_workers, :by_queue)

        def self.available?
          true
        end

        def initialize
          @overview_stats = Sidekiq::Stats.new
          @queues_stats = queues_stats
          @workers_stats = workers_stats
          @max_processing_times = max_processing_times
        end

        def to_s
          TEMPLATE.result(binding).chomp!
        end

        private

        def queues_stats
          Sidekiq::Queue.all.map do |queue|
            QueueStats.new(queue.name, queue.size, queue.latency)
          end
        end

        def workers_stats
          workers_stats = WorkersStats.new(0, {})

          Sidekiq::ProcessSet.new.each_with_object(workers_stats) do |process, stats|
            stats.total_workers += process['concurrency'].to_i

            process['queues'].each do |queue|
              stats.by_queue[queue] ||= QueueWorkersStats.new(0, 0, 0)
              stats.by_queue[queue].processes += 1
              stats.by_queue[queue].busy_workers += process['busy'].to_i
              stats.by_queue[queue].total_workers += process['concurrency'].to_i
            end
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
end
