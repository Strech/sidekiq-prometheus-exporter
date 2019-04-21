# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidekiq::Prometheus::Exporter::Exporters do
  let(:instance) { described_class.new }
  let(:exporters) do
    {standard: StandardMock, contrib: ContribMock, unavailable: UnavailableContribMock}
  end

  before do
    stub_const("#{described_class}::AVAILABLE_EXPORTERS", exporters)

    allow(StandardMock).to receive(:available?).and_return(true)
    allow(ContribMock).to receive(:available?).and_return(true)
    allow(UnavailableContribMock).to receive(:available?).and_return(false)

    allow_any_instance_of(StandardMock).to receive(:to_s).and_return('Standard')
    allow_any_instance_of(ContribMock).to receive(:to_s).and_return('Contrib')
    allow_any_instance_of(UnavailableContribMock).to receive(:to_s).and_return('UnavailableContrib')
  end

  describe '#exporters=' do
    context 'when auto-detect is the single value' do
      before { instance.exporters = %i(auto_detect) }

      it { expect(instance.to_s).to eq("Standard\nContrib") }
    end

    context 'when auto-detect mixed with other values' do
      before { instance.exporters = %i(standard auto_detect contrib) }

      it { expect(instance.to_s).to eq("Standard\nContrib") }
    end

    context 'when values are duplicated' do
      before { instance.exporters = %i(standard standard contrib contrib) }

      it { expect(instance.to_s).to eq("Standard\nContrib") }
    end

    context 'when standard value is given' do
      before { instance.exporters = %i(standard) }

      it { expect(instance.to_s).to eq('Standard') }
    end

    context 'when unavailable contrib value is given' do
      before { instance.exporters = %i(unavailable) }

      it { expect(instance.to_s).to eq('Standard') }
    end

    context 'when nothing is given' do
      before { instance.exporters = [] }

      it { expect(instance.to_s).to eq('Standard') }
    end
  end

  describe '#to_s' do
    it { expect(instance.to_s).to eq("Standard\nContrib") }
  end
end
