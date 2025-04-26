# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/prometheus/exporter/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidekiq-prometheus-exporter'
  spec.version       = Sidekiq::Prometheus::Exporter::VERSION
  spec.authors       = ['Sergey Fedorov']
  spec.email         = %w(oni.strech@gmail.com)
  spec.license       = 'MIT'
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
    file.match(%r{^(.github|docker|examples|gemfiles|helm|test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |file| File.basename(file) }
  spec.require_paths = %w(lib)

  spec.required_ruby_version = '>= 2.5'
  spec.add_dependency 'rack', '>= 1.6.0'
  spec.add_dependency 'sidekiq', '>= 4.1.0'
end
