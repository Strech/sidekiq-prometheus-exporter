require 'sidekiq'
require 'sidekiq/prometheus/exporter'

Sidekiq.configure_client do |config|
  config.redis = {url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}"}
end

run Sidekiq::Prometheus::Exporter.to_app
