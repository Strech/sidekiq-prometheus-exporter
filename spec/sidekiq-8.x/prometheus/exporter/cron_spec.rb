# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidekiq::Prometheus::Exporter::Cron do
  describe '#to_s' do
    let(:exporter) { described_class.new }
    let(:metrics_text) do
      <<~TEXT.chomp
        # HELP sidekiq_cron_jobs The number of cron jobs.
        # TYPE sidekiq_cron_jobs gauge
        sidekiq_cron_jobs 42
      TEXT
    end

    before do
      stub_const('Sidekiq::Cron', SidekiqCronMock)

      allow(SidekiqCronMock::Job).to receive(:count).and_return(42)
    end

    it { expect(exporter.to_s).to eq(metrics_text) }
  end
end
