# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidekiq::Prometheus::Exporter::Standard do
  describe '#to_s' do
    let(:exporter) { described_class.new }
    let(:stats) do
      instance_double(
        Sidekiq::Stats, processed: 10, failed: 9, workers_size: 8, enqueued: 7,
                        scheduled_size: 6, retry_size: 5, dead_size: 4, processes_size: 2
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
          'hostname' => 'host01',
          'started_at' => 15560273303044038,
          'pid' => 1,
          'tag' => 'background-1',
          'concurrency' => 32,
          'queues' => %w(default),
          'labels' => [],
          'identity' => 'host01:1:2a21ce641404',
          'busy' => 2,
          'beat' => 15562263399993315,
          'quiet' => 'false'
        },
        {
          'hostname' => 'host01',
          'started_at' => now.to_i - 100,
          'pid' => 2,
          'tag' => 'background-2',
          'concurrency' => 32,
          'queues' => %w(default),
          'labels' => [],
          'identity' => 'host01:1:2a00ce741405',
          'busy' => 6,
          'beat' => 1556226339.9993315,
          'quiet' => 'true'
        },
        {
          'hostname' => 'host01',
          'started_at' => 15560273303044038,
          'pid' => 1,
          'tag' => 'background-3',
          'concurrency' => 10,
          'queues' => %w(additional),
          'labels' => [],
          'identity' => 'host02:1:caadfbfe6cf8',
          'busy' => 2,
          'beat' => 15562263399993315,
          'quiet' => 'false'
        },
        {
          'hostname' => 'host02',
          'started_at' => 15560273303044038,
          'pid' => 1,
          'tag' => 'background-4',
          'concurrency' => 32,
          'queues' => %w(default additional),
          'labels' => [],
          'identity' => 'host03:1:0ac802b40e1f',
          'busy' => 8,
          'beat' => 15562263399993315,
          'quiet' => 'false'
        }
      ]
    end
    let(:process_set) { SidekiqProcessSetMock.new(processes) }

    context 'when sidekiq was launched once and metrics have values' do
      before do
        Timecop.freeze(now)

        allow(Sidekiq::Stats).to receive(:new).and_return(stats)
        allow(Sidekiq::Queue).to receive(:all).and_return(queues)
        allow(Sidekiq::Workers).to receive(:new).and_return(workers)
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set)
      end

      context 'when sidekiq is runnin community version' do
        before { allow(process_set).to receive(:leader).and_return('') }

        it { expect(exporter.to_s).to eq(fixture('community_version_without_memory_usage')) }
      end

      context 'when sidekiq is runnin enterprise version' do
        before { allow(process_set).to receive(:leader).and_return('host01:1:2a00ce741405') }

        it { expect(exporter.to_s).to eq(fixture('enterprise_version_without_memory_usage')) }
      end

      context 'when sidekiq process has RSS metric' do
        before do
          processes.each { |process| process['rss'] = 1 }
          allow(process_set).to receive(:leader).and_return('')
        end

        it { expect(exporter.to_s).to eq(fixture('community_version_with_memory_usage')) }
      end
    end

    context 'when sidekiq was never launched' do
      let(:stats) do
        instance_double(
          Sidekiq::Stats, processed: 0, failed: 0, workers_size: 0, enqueued: 0,
                          scheduled_size: 0, retry_size: 0, dead_size: 0, processes_size: 0
        )
      end

      before do
        Timecop.freeze(now)

        allow(Sidekiq::Stats).to receive(:new).and_return(stats)
        allow(Sidekiq::Queue).to receive(:all).and_return([])
        allow(Sidekiq::Workers).to receive(:new).and_return([])
        allow(Sidekiq::ProcessSet).to receive(:new).and_return([])
      end

      it { expect { exporter.to_s }.not_to raise_error }
    end
  end
end
