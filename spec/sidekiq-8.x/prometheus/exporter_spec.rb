# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidekiq::Prometheus::Exporter do
  let(:app) do
    # Re-assemble Rack application manually
    # to be able to to behave like Rack 2.2.
    #
    # Related: https://github.com/Strech/sidekiq-prometheus-exporter/issues/21
    klass = described_class
    Rack::Builder.app do
      use Rack::ETag
      map(klass::MOUNT_PATH) { run klass }
    end
  end
  let(:response) { last_response }

  context 'when requested metrics url' do
    let(:stats) do
      instance_double(
        Sidekiq::Stats, processed: 10, failed: 9, workers_size: 8, enqueued: 7,
                        scheduled_size: 6, retry_size: 5, dead_size: 4, processes_size: 1
      )
    end
    let(:queues) do
      [
        instance_double(Sidekiq::Queue, name: 'default', size: 1, latency: 24.32109676),
        instance_double(Sidekiq::Queue, name: 'additional', size: 0, latency: 1.00200001)
      ]
    end
    let(:now) { Time.now }
    let(:workers) do
      [
        [
          'worker1:1:0493e4117adb',
          '2oe',
          instance_double(
            Sidekiq::Work,
            process_id: 'worker1:1:0493e4117adb', thread_id: '2oe', queue: 'default', run_at: now - 10
          )
        ],
        [
          'worker1:1:0493e4117adb',
          '2si',
          instance_double(
            Sidekiq::Work,
            process_id: 'worker1:1:0493e4117adb', thread_id: '2si', queue: 'default', run_at: now - 20
          )
        ],
        [
          'worker2:1:dbf573ecf819',
          '2hi',
          instance_double(
            Sidekiq::Work,
            process_id: 'worker2:1:dbf573ecf819', thread_id: '2hi', queue: 'additional', run_at: now - 30
          )
        ],
        [
          'worker2:1:dbf573ecf819',
          '2s8',
          instance_double(
            Sidekiq::Work,
            process_id: 'worker2:1:dbf573ecf819', thread_id: '2s8', queue: 'additional', run_at: now - 40
          )
        ]
      ]
    end
    let(:processes) do
      [
        {
          'hostname' => '27af38b7f22e',
          'started_at' => 15560273303044038,
          'pid' => 1,
          'tag' => 'background-1',
          'concurrency' => 32,
          'queues' => %w(default),
          'labels' => [],
          'identity' => '27af38b7f22e:1:2a21ce641404',
          'busy' => 2,
          'beat' => 15562263399993315,
          'quiet' => 'false'
        }
      ]
    end

    before do
      Timecop.freeze(now)

      allow(Sidekiq).to receive(:redis).and_return(stats)
      allow(Sidekiq::Stats).to receive(:new).and_return(stats)
      allow(Sidekiq::Queue).to receive(:all).and_return(queues)
      allow(Sidekiq::Workers).to receive(:new).and_return(workers)
      allow(Sidekiq::ProcessSet).to receive(:new).and_return(processes)

      get '/metrics'
    end

    it { expect(response).to be_ok }
    it { expect(response.body).to include('sidekiq_busy_workers 8') }
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

  describe '#banner' do
    it { expect(described_class.banner).to eq("Enabled Sidekiq Prometheus exporters:\n  - standard") }
  end
end
