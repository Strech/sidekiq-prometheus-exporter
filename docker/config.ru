# frozen_string_literal: true

require 'cgi'
require 'sidekiq'
require 'sidekiq/prometheus/exporter'

config = {}
config[:url] = ENV['REDIS_URL'] if ENV.key?('REDIS_URL')

unless config.key?(:url)
  scheme = (ENV.fetch('REDIS_SSL', 'false') == 'true') ? 'rediss' : 'redis'
  host = ENV.fetch('REDIS_HOST', 'localhost')
  port = ENV.fetch('REDIS_PORT', 6379)
  db_number = ENV.fetch('REDIS_DB_NUMBER', 0)

  credentials = CGI.escape(ENV.fetch('REDIS_USERNAME', ''))
  credentials = "#{credentials}:#{CGI.escape(ENV['REDIS_PASSWORD'])}" if ENV.key?('REDIS_PASSWORD')
  credentials = "#{credentials}@" unless credentials.empty?

  config[:url] = "#{scheme}://#{credentials}#{host}:#{port}/#{db_number}"
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
    cfg = {host: uri.host || 'localhost', port: uri.port || 26379} # rubocop:disable Style/NumericLiterals
    cfg[:password] = ":#{uri.password}" if uri.password
    cfg
  end
end

config[:id] = nil if ENV.key?('REDIS_DISABLE_CLIENT_ID')

Sidekiq.configure_client { |client| client.redis = config }

run Sidekiq::Prometheus::Exporter.to_app
