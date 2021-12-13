# frozen_string_literal: true

require 'erb'
require 'sidekiq/api'

module Sidekiq
  module Prometheus
    module Exporter
      class Standard
        TEMPLATE = ERB.new(File.read(File.expand_path('templates/standard.erb', __dir__)))

        QueueStats = Struct.new(:name, :size, :latency)

        def self.available?
          true
        end

        def initialize
          @overview_stats = Sidekiq::Stats.new
          @queues_stats = queues_stats
          @max_processing_times = max_processing_times
          @total_workers = total_workers
          @workers_stats_by_queue = workers_stats_by_queue
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

        def total_workers
          sidekiq_processes.sum { |process| process['concurrency'].to_i }
        end

        def workers_stats_by_queue
          sidekiq_processes.each_with_object({}) do |process, by_queue|
            process['queues'].each do |queue|
              by_queue[queue] ||= { 'workers' => 0, 'processes' => 0, 'busy_workers' => 0 }
              by_queue[queue]['workers'] += process['concurrency']
              by_queue[queue]['busy_workers'] += process['busy']
              by_queue[queue]['processes'] += 1
            end

            by_queue
          end
        end

        def sidekiq_processes
          @sidekiq_processes ||= Sidekiq::ProcessSet.new
        end
      end
    end
  end
end
