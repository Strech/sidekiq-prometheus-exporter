# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidekiq::Prometheus::Exporter::Scheduler do
  describe '#to_s' do
    let(:exporter) { described_class.new }
    let(:schedule) do
      {
        'job-once-per-day' => {
          'description' => 'This job runs every 24 hours',
          'every' => '24h',
          'class' => 'OncePerDayWorker',
          'args' => [],
          'queue' => 'default'
        },
        'job-never-runs' => {
          'description' => 'This job still never run',
          'every' => '1y',
          'class' => 'OncePerYearWorker',
          'args' => [],
          'queue' => 'default'
        },
        'job-runs-once-and-disabled' => {
          'description' => 'This job is disabled',
          'every' => '1m',
          'class' => 'OncePerMinuteWorker',
          'args' => [],
          'queue' => 'default'
        }
      }
    end
    let(:metrics_text) do
      <<~TEXT
        # HELP sidekiq_scheduler_jobs The number of recurring jobs.
        # TYPE sidekiq_scheduler_jobs gauge
        sidekiq_scheduler_jobs 3

        # HELP sidekiq_scheduler_enabled_jobs The number of enabled recurring jobs.
        # TYPE sidekiq_scheduler_enabled_jobs gauge
        sidekiq_scheduler_enabled_jobs 2

        # HELP sidekiq_scheduler_time_since_last_run_minutes The number of minutes since the last recurring job was executed and current time.
        # TYPE sidekiq_scheduler_time_since_last_run_minutes gauge
        sidekiq_scheduler_time_since_last_run_minutes{name="job-once-per-day"} 248
      TEXT
    end

    before do
      Timecop.freeze(Time.parse('2000-01-01 17:30:00 +0000'))

      stub_const('Sidekiq', SidekiqSchedulerMock::Sidekiq)
      stub_const('SidekiqScheduler::RedisManager', SidekiqSchedulerMock::RedisManager)

      allow(Sidekiq).to receive(:schedule!).and_return(schedule)

      allow(Sidekiq::Scheduler).to receive(:job_enabled?)
        .with('job-once-per-day').and_return(true)
      allow(Sidekiq::Scheduler).to receive(:job_enabled?)
        .with('job-never-runs').and_return(true)
      allow(Sidekiq::Scheduler).to receive(:job_enabled?)
        .with('job-runs-once-and-disabled').and_return(false)

      allow(SidekiqSchedulerMock::RedisManager).to receive(:get_job_last_time)
        .with('job-once-per-day').and_return('2000-01-01 13:21:59 +0000')
      allow(SidekiqSchedulerMock::RedisManager).to receive(:get_job_last_time)
        .with('job-never-runs').and_return(nil)
      allow(SidekiqSchedulerMock::RedisManager).to receive(:get_job_last_time)
        .with('job-runs-once-and-disabled').and_return('2000-01-01 15:30:00 +0000')
    end

    it { expect(exporter.to_s).to eq(metrics_text) }
  end
end
