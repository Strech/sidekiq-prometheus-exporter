require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

# ==============================================================================

require 'English'
require 'fileutils'
require_relative 'lib/sidekiq/prometheus/exporter/version'

VERSION = Sidekiq::Prometheus::Exporter::VERSION

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
  task :release do
    Rake::Task['docker:build'].invoke
    Rake::Task['docker:push'].invoke
  end

  task :build do
    image = 'strech/sidekiq-prometheus-exporter'

    Dir.chdir(File.expand_path('./docker')) do
      execute("docker build -t #{image}:#{VERSION} -t #{image}:latest .")
    end

    puts "Successfully built strech/sidekiq-prometheus-exporter and tagged #{VERSION} (latest)"
  end

  task :push do
    image = 'strech/sidekiq-prometheus-exporter'

    execute("docker push #{image}:#{VERSION}")
    execute("docker push #{image}:latest")

    puts "Successfully pushed strech/sidekiq-prometheus-exporter:#{VERSION} (latest)"
  end
end

namespace :helm do
  desc 'Generate new Helm repo index'
  task :generate do
    archive_dir = File.expand_path("./tmp/archive-#{Time.now.to_i}")

    Rake::Task['helm:package'].invoke(archive_dir)
    Rake::Task['helm:index'].invoke(archive_dir)

    puts "New index generated: #{File.join(archive_dir, 'index.yaml')}"
  end

  task :package, [:directory] do |_, args|
    chart_dir = File.expand_path('./helm/sidekiq-prometheus-exporter')
    archive_dir = args.fetch(:directory) { File.expand_path("./tmp/archive-#{Time.now.to_i}") }

    FileUtils.mkdir_p(archive_dir)

    execute("helm package #{chart_dir} -d #{archive_dir}")
  end

  task :index, [:directory] do |_, args|
    Dir.chdir(args.fetch(:directory)) do
      url = "https://github.com/Strech/sidekiq-prometheus-exporter/releases/download/v#{VERSION}"

      execute('git show gh-pages:index.yaml > existing-index.yaml')
      execute("helm repo index . --url #{url} --merge existing-index.yaml")
    end
  end
end
