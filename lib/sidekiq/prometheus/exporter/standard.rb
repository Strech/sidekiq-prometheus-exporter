# frozen_string_literal: true

require 'erb'
require 'sidekiq/api'

module Sidekiq
  module Prometheus
    module Exporter
      class Standard
        TEMPLATE = ERB.new(File.read(File.expand_path('templates/standard.erb', __dir__)))

        QueueStats = Struct.new(:name, :size, :latency, keyword_init: true)
        QueueWorkersStats = Struct.new(
          :total_workers, :busy_workers, :processes, keyword_init: true
        )
        WorkersStats = Struct.new(
          :total_workers, :by_queue, :by_host, :leader_lifetime, keyword_init: true
        )

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
            QueueStats.new(name: queue.name, size: queue.size, latency: queue.latency)
          end
        end

        def workers_stats
          workers_stats = WorkersStats.new(total_workers: 0, by_queue: {}, by_host: {})

          processes = Sidekiq::ProcessSet.new

          # NOTE: available only on enterprise starting v5.0.1
          leader_identity = processes.leader if processes.respond_to?(:leader)

          processes.each_with_object(workers_stats) do |process, stats|
            stats.total_workers += process['concurrency'].to_i

            stats.by_host[process['hostname']] ||= Hash.new(0)
            stats.by_host[process['hostname']][process['quiet']] += 1

            process['queues'].each do |queue|
              stats.by_queue[queue] ||= QueueWorkersStats.new(
                total_workers: 0, busy_workers: 0, processes: 0
              )

              stats.by_queue[queue].processes += 1
              stats.by_queue[queue].busy_workers += process['busy'].to_i
              stats.by_queue[queue].total_workers += process['concurrency'].to_i
            end

            if process['identity'] == leader_identity
              stats.leader_lifetime = Time.now.utc.to_i - process['started_at']
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
