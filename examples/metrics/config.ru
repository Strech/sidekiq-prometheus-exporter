# frozen_string_literal: true

if ENV.key?('LOCAL')
  lib = File.expand_path('../sidekiq-prometheus-exporter/lib', __dir__)
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

require 'sidekiq'
require 'sidekiq/prometheus/exporter'

Sidekiq.configure_client do |config|
  config.redis = {url: 'redis://redis:6379/0'}
end

run Sidekiq::Prometheus::Exporter.to_app
