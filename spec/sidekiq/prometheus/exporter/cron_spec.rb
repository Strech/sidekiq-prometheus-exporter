# frozen_string_literal: true

require 'spec_helper'
require 'support/sidekiq_cron'

RSpec.describe Sidekiq::Prometheus::Exporter::Cron do
  describe '#to_s' do
    let(:exporter) { described_class.new }
    let(:metrics_text) do
      # rubocop:disable Layout/IndentHeredoc
      <<-TEXT.chomp
# HELP sidekiq_cron_jobs The number of cron jobs.
# TYPE sidekiq_cron_jobs gauge
sidekiq_cron_jobs 42
      TEXT
      # rubocop:enable Layout/IndentHeredoc
    end

    before { allow(Sidekiq::Cron::Job).to receive(:count).and_return(42) }

    it { expect(exporter.to_s).to eq(metrics_text) }
  end
end
