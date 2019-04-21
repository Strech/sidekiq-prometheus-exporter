# frozen_string_literal: true

require 'sidekiq/prometheus/exporter/standard'
require 'sidekiq/prometheus/exporter/cron'

module Sidekiq
  module Prometheus
    module Exporter
      class Exporters
        AVAILABLE_EXPORTERS = {
          standard: Sidekiq::Prometheus::Exporter::Standard,
          cron: Sidekiq::Prometheus::Exporter::Cron
        }.freeze

        def initialize
          @enabled = AVAILABLE_EXPORTERS.values.select(&:available?)
        end

        def exporters=(value)
          value = Array(value) unless value.respond_to?(:select)
          potential = AVAILABLE_EXPORTERS

          unless value.include?(:auto_detect)
            potential = potential.select { |name, _| value.include?(name) }
          end

          @enabled =
            %i(standard).concat(potential.keys).uniq
              .map { |name| AVAILABLE_EXPORTERS.fetch(name) }
              .select(&:available?)
        end

        def to_s
          @enabled.map { |exporter| exporter.new.to_s }.join("\n".freeze)
        end
      end
    end
  end
end
