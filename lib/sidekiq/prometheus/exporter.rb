# frozen_string_literal: true

require 'sidekiq/prometheus/exporter/version'
require 'sidekiq/prometheus/exporter/exporters'

module Sidekiq
  module Prometheus
    # Expose Prometheus metrics via Rack application or Sidekiq::Web application
    module Exporter
      REQUEST_VERB = 'GET'.freeze
      REQUEST_METHOD = 'REQUEST_METHOD'.freeze
      NOT_FOUND_TEXT = 'Not Found'.freeze
      MOUNT_PATH = '/metrics'.freeze
      # rubocop:disable Style/MutableConstant
      HEADERS = {'Content-Type' => 'text/plain; version=0.0.4', 'Cache-Control' => 'no-cache'}
      # rubocop:enable Style/MutableConstant
      EXPORTERS = Exporters.new

      class << self
        def banner
          exporters =
            EXPORTERS.enabled
              .map { |klass| "  - #{klass.name.split('::').last.downcase}" }
              .join("\n".freeze)

          "Enabled Sidekiq Prometheus exporters:\n#{exporters}"
        end

        def configure
          yield(EXPORTERS)
        end

        def registered(app)
          app.get(MOUNT_PATH) do
            Sidekiq::Prometheus::Exporter.call(REQUEST_METHOD => REQUEST_VERB)
          end
        end

        def to_app
          Rack::Builder.app do
            map(MOUNT_PATH) do
              run Sidekiq::Prometheus::Exporter
            end
          end
        end

        def call(env)
          return [404, HEADERS, [NOT_FOUND_TEXT]] if env[REQUEST_METHOD] != REQUEST_VERB

          [200, HEADERS, [EXPORTERS.to_s]]
        end
      end
    end
  end
end
