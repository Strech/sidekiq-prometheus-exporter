# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t, args|
  require 'sidekiq/version'
  directory = Sidekiq::VERSION.start_with?('8') ? 'sidekiq-8.x' : 'sidekiq'

  t.pattern = "spec/#{directory}/**/*_spec.rb"
  t.rspec_opts = args.to_a.join(' ')
end

task default: :spec

# ==============================================================================

require 'English'
require 'fileutils'
require_relative 'lib/sidekiq/prometheus/exporter/version'

VERSION = Sidekiq::Prometheus::Exporter::VERSION
DOCKER_PATCH_VERSION = Sidekiq::Prometheus::Exporter::DOCKER_PATCH_VERSION

def execute(command)
  output = `#{command}`

  unless $CHILD_STATUS.success?
    warn output
    exit 1
  end

  output
end

def docker_version
  patch = DOCKER_PATCH_VERSION unless DOCKER_PATCH_VERSION.to_i.zero?
  [VERSION, patch].compact.join('-')
end

namespace :docker do
  desc "Release new Docker image strech/sidekiq-prometheus-exporter:#{docker_version} (latest)"
  task :release, %i(version) do |_, args|
    version = args.fetch(:version, docker_version)

    Rake::Task['docker:build'].invoke(version)
    Rake::Task['docker:push'].invoke(version)
  end

  task :build, %i(version) do |_, args|
    args.with_defaults(version: docker_version)
    image = 'strech/sidekiq-prometheus-exporter'

    Dir.chdir(File.expand_path('./docker')) do
      execute("docker buildx build --platform linux/amd64,linux/arm64 -t #{image}:#{args.version} -t #{image}:latest .")
    end

    puts "Successfully built strech/sidekiq-prometheus-exporter and tagged #{args.version} (latest)"
  end

  task :push, %i(version) do |_, args|
    args.with_defaults(version: docker_version)
    image = 'strech/sidekiq-prometheus-exporter'

    # rubocop:disable Layout/LineLength
    Dir.chdir(File.expand_path('./docker')) do
      execute("docker buildx build --push --platform linux/amd64,linux/arm64 -t #{image}:#{args.version} -t #{image}:latest .")
    end
    # rubocop:enable Layout/LineLength

    puts "Successfully pushed strech/sidekiq-prometheus-exporter:#{args.version} (latest)"
  end
end

namespace :helm do
  desc 'Generate new Helm repo index'
  task :generate, %i(version) do |_, args|
    args.with_defaults(version: docker_version)
    archive_dir = File.expand_path("./tmp/archive-#{Time.now.to_i}")

    Rake::Task['helm:package'].invoke(archive_dir)
    Rake::Task['helm:index'].invoke(archive_dir, args.version)

    puts "New index generated: #{File.join(archive_dir, 'index.yaml')}"
  end

  task :package, %i(directory) do |_, args|
    chart_dir = File.expand_path('./helm/sidekiq-prometheus-exporter')
    archive_dir = args.fetch(:directory) { File.expand_path("./tmp/archive-#{Time.now.to_i}") }

    FileUtils.mkdir_p(archive_dir)

    execute("helm package #{chart_dir} -d #{archive_dir}")
  end

  task :index, %i(directory version) do |_, args|
    args.with_defaults(version: docker_version)

    Dir.chdir(args.fetch(:directory)) do
      url = "https://github.com/Strech/sidekiq-prometheus-exporter/releases/download/v#{args.version}"

      execute('git show gh-pages:index.yaml > existing-index.yaml')
      execute("helm repo index . --url #{url} --merge existing-index.yaml")
    end
  end
end
