require 'bundler/setup'
require 'rack/test'
require 'simplecov'
require 'sidekiq/web'
require 'timecop'

SimpleCov.start

require 'sidekiq/prometheus/exporter'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.example_status_persistence_file_path = '.rspec_status'
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
