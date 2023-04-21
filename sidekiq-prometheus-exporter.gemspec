# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/prometheus/exporter/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidekiq-prometheus-exporter'
  spec.version       = Sidekiq::Prometheus::Exporter::VERSION
  spec.authors       = ['Sergey Fedorov']
  spec.email         = %w(oni.strech@gmail.com)

  spec.summary       = 'Prometheus exporter for the Sidekiq'
  spec.description   = 'All the basic metrics prepared for Prometheus'
  spec.homepage      = 'https://github.com/Strech/sidekiq-prometheus-exporter'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
    spec.metadata['rubygems_mfa_required'] = 'true'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |file|
    file.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |file| File.basename(file) }
  spec.require_paths = %w(lib)

  spec.required_ruby_version = '>= 2.3'
  spec.add_dependency 'rack', '>= 1.6.0'
  spec.add_dependency 'sidekiq', '>= 3.3.1'

  spec.add_development_dependency 'appraisal',                 '~> 2.2'
  spec.add_development_dependency 'bundler',                   '~> 2.1'
  spec.add_development_dependency 'pry-byebug',                '~> 3.6'
  spec.add_development_dependency 'pry',                       '~> 0.14'
  spec.add_development_dependency 'rack-test',                 '~> 1.1'
  spec.add_development_dependency 'rake',                      '~> 13.0'
  spec.add_development_dependency 'rspec',                     '~> 3.0'
  spec.add_development_dependency 'rubocop',                   '~> 1.22'
  spec.add_development_dependency 'rubocop-performance',       '~> 1.12'
  spec.add_development_dependency 'rubocop-rake',              '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec',             '~> 2.6'
  spec.add_development_dependency 'timecop',                   '~> 0.9'
end
