# frozen_string_literal: true

require 'erb'
require 'sidekiq/prometheus/exporter/version'
require 'sidekiq/prometheus/exporter/standard'

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

      def self.registered(app)
        app.get('/metrics') do
          Sidekiq::Prometheus::Exporter.call(REQUEST_METHOD => HTTP_GET)
        end
      end

      def self.to_app
        Rack::Builder.app do
          map('/metrics') do
            run Sidekiq::Prometheus::Exporter
          end
        end
      end

      def self.call(env)
        return [404, HEADERS, [NOT_FOUND_TEXT]] if env[REQUEST_METHOD] != HTTP_GET

        body = Standard.new.to_s
        [200, HEADERS, [body]]
      end
    end
  end
end
