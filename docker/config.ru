# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/prometheus/exporter'

config = {}
config[:url] = ENV['REDIS_URL'] if ENV.key?('REDIS_URL')

unless config.key?(:url)
  host = ENV.fetch('REDIS_HOST', 'localhost')
  port = ENV.fetch('REDIS_PORT', 6379)
  db_number = ENV.fetch('REDIS_DB_NUMBER', 0)
  password = ":#{ENV['REDIS_PASSWORD']}" if ENV.key?('REDIS_PASSWORD')

  config[:url] = "redis://#{password}#{host}:#{port}/#{db_number}"
end

if ENV.key?('REDIS_NAMESPACE')
  require 'redis-namespace'

  config[:namespace] = ENV['REDIS_NAMESPACE']
end

if ENV.key?('REDIS_SENTINELS')
  require 'uri'

  config[:role] = ENV.fetch('REDIS_SENTINEL_ROLE', :master).to_sym
  config[:sentinels] = ENV['REDIS_SENTINELS'].split(',').map do |url|
    uri = URI.parse(url.strip)
    cfg = {host: uri.host || 'localhost', port: uri.port || 26379}
    cfg[:password] = ":#{uri.password}" if uri.password
    cfg
  end
end

Sidekiq.configure_client { |client| client.redis = config }

run Sidekiq::Prometheus::Exporter.to_app
