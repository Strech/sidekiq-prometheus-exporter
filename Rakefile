require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

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

namespace :docker do
  desc "Release new Docker image strech/sidekiq-prometheus-exporter:#{VERSION} (latest)"
  task :release, %i(patch) do |_, args|
    version = [VERSION, args.fetch(:patch, DOCKER_PATCH_VERSION)].compact.join('-')

    Rake::Task['docker:build'].invoke(version)
    Rake::Task['docker:push'].invoke(version)
  end

  task :build, %i(version) do |_, args|
    args.with_defaults(version: VERSION)
    image = 'strech/sidekiq-prometheus-exporter'

    Dir.chdir(File.expand_path('./docker')) do
      execute("docker build -t #{image}:#{args.version} -t #{image}:latest .")
    end

    puts "Successfully built strech/sidekiq-prometheus-exporter and tagged #{args.version} (latest)"
  end

  task :push, %i(version) do |_, args|
    args.with_defaults(version: VERSION)
    image = 'strech/sidekiq-prometheus-exporter'

    execute("docker push #{image}:#{args.version}")
    execute("docker push #{image}:latest")

    puts "Successfully pushed strech/sidekiq-prometheus-exporter:#{args.version} (latest)"
  end
end

namespace :helm do
  desc 'Generate new Helm repo index'
  task :generate, %i(patch) do |_, args|
    version = [VERSION, args.patch].compact.join('-')
    archive_dir = File.expand_path("./tmp/archive-#{Time.now.to_i}")

    Rake::Task['helm:package'].invoke(archive_dir)
    Rake::Task['helm:index'].invoke(archive_dir, version)

    puts "New index generated: #{File.join(archive_dir, 'index.yaml')}"
  end

  task :package, %i(directory) do |_, args|
    chart_dir = File.expand_path('./helm/sidekiq-prometheus-exporter')
    archive_dir = args.fetch(:directory) { File.expand_path("./tmp/archive-#{Time.now.to_i}") }

    FileUtils.mkdir_p(archive_dir)

    execute("helm package #{chart_dir} -d #{archive_dir}")
  end

  task :index, %i(directory version) do |_, args|
    args.with_defaults(version: VERSION)

    Dir.chdir(args.fetch(:directory)) do
      url = "https://github.com/Strech/sidekiq-prometheus-exporter/releases/download/v#{args.version}"

      execute('git show gh-pages:index.yaml > existing-index.yaml')
      execute("helm repo index . --url #{url} --merge existing-index.yaml")
    end
  end
end
