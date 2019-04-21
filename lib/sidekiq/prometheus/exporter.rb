# frozen_string_literal: true

require 'sidekiq/prometheus/exporter/version'
require 'sidekiq/prometheus/exporter/standard'
require 'sidekiq/prometheus/exporter/cron'

module Sidekiq
  module Prometheus
    # Expose Prometheus metrics via Rack application or Sidekiq::Web application
    module Exporter
      REQUEST_VERB = 'GET'.freeze
      REQUEST_METHOD = 'REQUEST_METHOD'.freeze
      NOT_FOUND_TEXT = 'Not Found'.freeze
      MOUNT_PATH = '/metrics'.freeze
      HEADERS = {'Content-Type' => 'text/plain; version=0.0.4', 'Cache-Control' => 'no-cache'}.freeze

      def self.registered(app)
        app.get(MOUNT_PATH) do
          Sidekiq::Prometheus::Exporter.call(REQUEST_METHOD => REQUEST_VERB)
        end
      end

      def self.to_app
        Rack::Builder.app do
          map(MOUNT_PATH) do
            run Sidekiq::Prometheus::Exporter
          end
        end
      end

      def self.call(env)
        return [404, HEADERS, [NOT_FOUND_TEXT]] if env[REQUEST_METHOD] != REQUEST_VERB

        body = Standard.new.to_s
        [200, HEADERS, [body]]
      end
    end
  end
end
