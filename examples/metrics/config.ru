# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/prometheus/exporter'

Sidekiq.configure_client do |config|
  config.redis = {url: 'redis://redis:6379/0'}
end

run Sidekiq::Prometheus::Exporter.to_app
