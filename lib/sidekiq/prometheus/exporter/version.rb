# frozen_string_literal: true

module Sidekiq
  module Prometheus
    module Exporter
      # NOTE: Every version update dropds Docker patch version to 0
      #       and every adjustment in Docker setup bumps it to +1
      VERSION = '0.2.0'.freeze
      DOCKER_PATCH_VERSION = '2'.freeze
    end
  end
end
