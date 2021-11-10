# frozen_string_literal: true

class SleepyWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default

  def perform
    sleep rand(1...10)
  end
end

class BrokenWorker
  include Sidekiq::Worker

  sidekiq_options queue: :critical,
                  retry: 5

  def perform
    raise 'Ooooooops ...'
  end
end

Sidekiq.configure_server do |config|
  config.redis = {url: 'redis://redis:6379/0'}
end

Sidekiq.configure_client do |config|
  config.redis = {url: 'redis://redis:6379/0'}
end

Thread.new do
  sleep 5

  loop do
    SleepyWorker.perform_async
    BrokenWorker.perform_async

    sleep rand(1..5)
  end
end
