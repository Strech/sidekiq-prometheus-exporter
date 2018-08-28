require 'spec_helper'

RSpec.describe Sidekiq::Prometheus::Exporter do
  let(:app) { described_class.to_app }
  let(:response) { last_response }

  context 'when requested metrics url' do
    let(:metrics_text) do
      # rubocop:disable Layout/IndentHeredoc
      <<-TEXT
# HELP sidekiq_processed_jobs_total The total number of processed jobs.
# TYPE sidekiq_processed_jobs_total counter
sidekiq_processed_jobs_total 10

# HELP sidekiq_failed_jobs_total The total number of failed jobs.
# TYPE sidekiq_failed_jobs_total counter
sidekiq_failed_jobs_total 9

# HELP sidekiq_busy_workers The number of workers performing the job.
# TYPE sidekiq_busy_workers gauge
sidekiq_busy_workers 8

# HELP sidekiq_enqueued_jobs The number of enqueued jobs.
# TYPE sidekiq_enqueued_jobs gauge
sidekiq_enqueued_jobs 7

# HELP sidekiq_scheduled_jobs The number of jobs scheduled for a future execution.
# TYPE sidekiq_scheduled_jobs gauge
sidekiq_scheduled_jobs 6

# HELP sidekiq_retry_jobs The number of jobs scheduled for the next try.
# TYPE sidekiq_retry_jobs gauge
sidekiq_retry_jobs 5

# HELP sidekiq_dead_jobs The number of jobs being dead.
# TYPE sidekiq_dead_jobs gauge
sidekiq_dead_jobs 4

# HELP sidekiq_queue_latency_seconds The amount of seconds between oldest job being pushed to the queue and current time.
# TYPE sidekiq_queue_latency_seconds gauge
sidekiq_queue_latency_seconds{name="default"} 24.321
sidekiq_queue_latency_seconds{name="additional"} 1.002
      TEXT
      # rubocop:enable Layout/IndentHeredoc
    end
    let(:stats) do
      instance_double(
        Sidekiq::Stats, processed: 10, failed: 9, workers_size: 8, enqueued: 7,
                        scheduled_size: 6, retry_size: 5, dead_size: 4
      )
    end
    let(:queues) do
      [
        instance_double(Sidekiq::Queue, name: 'default', size: 1, latency: 24.32109676),
        instance_double(Sidekiq::Queue, name: 'additional', size: 0, latency: 1.00200001)
      ]
    end

    before do
      allow(Sidekiq::Stats).to receive(:new).and_return(stats)
      allow(Sidekiq::Queue).to receive(:all).and_return(queues)

      get '/metrics'
    end

    it { expect(response).to be_ok }
    it { expect(response.body).to eq(metrics_text) }
    it { expect(response.headers['Content-Type']).to eq('text/plain; version=0.0.4') }
    it { expect(response.headers['Cache-Control']).to eq('no-cache') }
  end

  context 'when requested wrong http method' do
    before { post '/metrics' }

    it { expect(response).to be_not_found }
  end

  context 'when requested unknown url' do
    before { get '/unknown' }

    it { expect(response).to be_not_found }
  end

  context 'when registering in Sidekiq' do
    before do
      allow(Sinatra::Base).to receive(:get) if defined?(Sinatra)
      allow(Sidekiq::WebApplication).to receive(:get) if defined?(Sidekiq::WebApplication)

      Sidekiq::Web.register(described_class)
    end

    if defined?(Sinatra)
      it { expect(Sinatra::Base).to have_received(:get).with('/metrics') }
    end

    if defined?(Sidekiq::WebApplication)
      it { expect(Sidekiq::WebApplication).to have_received(:get).with('/metrics') }
    end
  end
end
