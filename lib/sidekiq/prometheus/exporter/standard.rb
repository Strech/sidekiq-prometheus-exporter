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
          Sidekiq::ProcessSet.new.map { |process| process['concurrency'] }.reduce(:+)
        end
      end
    end
  end
end
