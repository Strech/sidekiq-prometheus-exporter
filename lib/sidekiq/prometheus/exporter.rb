# frozen_string_literal: true

require 'sidekiq/prometheus/exporter/version'
require 'sidekiq/api'

module Sidekiq
  module Prometheus
    # Expose Prometheus metrics via Rack application or Sidekiq::Web application
    module Exporter
      HTTP_GET = 'GET'.freeze
      NOT_FOUND_TEXT = 'Not Found'.freeze
      REQUEST_METHOD = 'REQUEST_METHOD'.freeze
      HEADERS = {
        'Content-Type' => 'text/plain; version=0.0.4',
        'Cache-Control' => 'no-cache'
      }.freeze
      LATENCY_TEMPLATE = 'sidekiq_queue_latency_seconds{name="%<name>s"} %<latency>.3f'.freeze
      METRICS_TEMPLATE = <<-TEXT.gsub(/^[^\r\n][[:space:]]{2,}/, '').freeze
        # HELP sidekiq_processed_jobs_total The total number of processed jobs.
        # TYPE sidekiq_processed_jobs_total counter
        sidekiq_processed_jobs_total %<processed_jobs>d

        # HELP sidekiq_failed_jobs_total The total number of failed jobs.
        # TYPE sidekiq_failed_jobs_total counter
        sidekiq_failed_jobs_total %<failed_jobs>d

        # HELP sidekiq_busy_workers The number of workers performing the job.
        # TYPE sidekiq_busy_workers gauge
        sidekiq_busy_workers %<busy_workers>d

        # HELP sidekiq_enqueued_jobs The number of enqueued jobs.
        # TYPE sidekiq_enqueued_jobs gauge
        sidekiq_enqueued_jobs %<enqueued_jobs>d

        # HELP sidekiq_scheduled_jobs The number of jobs scheduled for a future execution.
        # TYPE sidekiq_scheduled_jobs gauge
        sidekiq_scheduled_jobs %<scheduled_jobs>d

        # HELP sidekiq_retry_jobs The number of jobs scheduled for the next try.
        # TYPE sidekiq_retry_jobs gauge
        sidekiq_retry_jobs %<retry_jobs>d

        # HELP sidekiq_dead_jobs The number of jobs being dead.
        # TYPE sidekiq_dead_jobs gauge
        sidekiq_dead_jobs %<dead_jobs>d

        # HELP sidekiq_queue_latency_seconds The amount of seconds between oldest job being pushed to the queue and current time.
        # TYPE sidekiq_queue_latency_seconds gauge
        %<queues_latency>s
      TEXT

      def self.to_app
        Rack::Builder.app do
          map('/metrics') do
            run Sidekiq::Prometheus::Exporter
          end
        end
      end

      def self.call(env)
        return [404, HEADERS, [NOT_FOUND_TEXT]] if env[REQUEST_METHOD] != HTTP_GET

        stats = Sidekiq::Stats.new
        queues_latency = Sidekiq::Queue.all.map do |queue|
          format(LATENCY_TEMPLATE, name: queue.name, latency: queue.latency)
        end
        body = format(
          METRICS_TEMPLATE,
          processed_jobs: stats.processed,
          scheduled_jobs: stats.scheduled_size,
          enqueued_jobs: stats.enqueued,
          failed_jobs: stats.failed,
          retry_jobs: stats.retry_size,
          dead_jobs: stats.dead_size,
          busy_workers: stats.workers_size,
          queues_latency: queues_latency * "\n"
        )

        [200, HEADERS, [body]]
      end

      def self.registered(app)
        app.get('/metrics') do
          Sidekiq::Prometheus::Exporter.call(REQUEST_METHOD => HTTP_GET)
        end
      end
    end
  end
end
