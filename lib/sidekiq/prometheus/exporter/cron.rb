# frozen_string_literal: true

require 'erb'

# Exporter for the https://github.com/ondrejbartas/sidekiq-cron
module Sidekiq
  module Prometheus
    module Exporter
      class Cron
        TEMPLATE = ERB.new(File.read(File.expand_path('templates/cron.erb', __dir__)))

        def self.available?
          defined?(Sidekiq::Cron)
        end

        def initialize
          @cron_jobs_count = Sidekiq::Cron::Job.count
        end

        def to_s
          TEMPLATE.result(binding).chomp!
        end
      end
    end
  end
end
