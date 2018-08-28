# frozen_string_literal: true

require 'sidekiq/api'

class Metrics
  QueueStats = Struct.new(:name, :size, :latency)

  def initialize
    @overview_stats = Sidekiq::Stats.new
    @queues_stats = queues_stats
  end

  private

  def queues_stats
    Sidekiq::Queue.all.map do |queue|
      QueueStats.new(queue.name, queue.size, queue.latency)
    end
  end
end
