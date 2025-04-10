# frozen_string_literal: true

require 'erb'
require 'sidekiq/api'

module Sidekiq
  module Prometheus
    module Exporter
      class Standard
        UNKNOWN_IDENTITY = 'unknown-identity'.freeze
        BYTES_IN_KILOBYTE = 1024
        OMIT_NEWLINES_MODE = '<>'.freeze
        TEMPLATE = ERB.new(
          File.read(File.expand_path('templates/standard.erb', __dir__)),
          trim_mode: OMIT_NEWLINES_MODE
        )

        HostStats = Struct.new(:memory_usage, :by_quiet, keyword_init: true)
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
          # Version dependent metrics
          @show_memory_usage = false

          @overview_stats = Sidekiq::Stats.new
          @queues_stats = queues_stats
          @workers_stats = workers_stats
          @max_processing_times = max_processing_times
        end

        def to_s
          TEMPLATE.result(binding)
        end

        private

        def queues_stats
          Sidekiq::Queue.all.map do |queue|
            QueueStats.new(name: queue.name, size: queue.size, latency: queue.latency)
          end
        end

        def workers_stats
          processes = Sidekiq::ProcessSet.new
          workers_stats = WorkersStats.new(total_workers: 0, by_queue: {}, by_host: {})

          # NOTE: available only on enterprise starting v5.0.1
          leader_identity =
            processes.respond_to?(:leader) ? processes.leader : UNKNOWN_IDENTITY

          processes.each_with_object(workers_stats) do |process, stats|
            stats.total_workers += process['concurrency'].to_i

            if process['identity'] == leader_identity
              stats.leader_lifetime = Time.now.utc.to_i - process['started_at']
            end

            collect_process_stats_by_host(process, stats.by_host)
            collect_process_stats_by_queue(process, stats.by_queue)
          end
        end

        def collect_process_stats_by_host(process, stats)
          stats[process['hostname']] ||= HostStats.new(memory_usage: 0, by_quiet: Hash.new(0))
          stats[process['hostname']].by_quiet[process['quiet']] += 1
          # NOTE: available only starting v6.2.0
          @show_memory_usage ||= true if process['rss']
          stats[process['hostname']].memory_usage += kilobytes_to_bytes(process['rss'].to_i)
        end

        def collect_process_stats_by_queue(process, stats)
          process['queues'].each do |queue|
            stats[queue] ||= QueueWorkersStats.new(
              total_workers: 0, busy_workers: 0, processes: 0
            )

            stats[queue].processes += 1
            stats[queue].busy_workers += process['busy'].to_i
            stats[queue].total_workers += process['concurrency'].to_i
          end
        end

        def kilobytes_to_bytes(kilobytes)
          kilobytes * BYTES_IN_KILOBYTE
        end

        def max_processing_times
          return new_max_processing_times if Sidekiq.const_defined?(:Work)

          now = Time.now.to_i

          Sidekiq::Workers.new
            .each_with_object({}) { |(_, _, work), memo| (memo[work['queue']] ||= []).push(work) }
            .transform_values! do |works|
              oldest_work = works.min_by { |work| work['run_at'] }
              now - oldest_work['run_at']
            end
        end

        # TODO: Internally Sidekiq::Work stores `run_at` as a timestamp.
        #       It would be great to use it instead of invoking `Time.at` call.
        #       See: https://github.com/sidekiq/sidekiq/blob/v8.0.0/lib/sidekiq/api.rb#L1253-L1255
        def new_max_processing_times
          now = Time.now

          Sidekiq::Workers.new
            .each_with_object({}) { |(_, _, work), memo| (memo[work.queue] ||= []).push(work) }
            .transform_values! { |works| now - works.min_by(&:run_at).run_at }
        end
      end
    end
  end
end
