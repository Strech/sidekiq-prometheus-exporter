require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

# ===============================================================================

require 'english'
require 'fileutils'
require_relative 'lib/sidekiq/prometheus/exporter/version'

namespace :helm do
  def execute(command)
    output = `#{command}`

    unless $CHILD_STATUS.success?
      warn output
      exit 1
    end

    output
  end

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
      url = "https://github.com/Strech/sidekiq-prometheus-exporter/releases/download/v#{Sidekiq::Prometheus::Exporter::VERSION}"

      execute('git show gh-pages:index.yaml > existing-index.yaml')
      execute("helm repo index . --url #{url} --merge existing-index.yaml")
    end
  end
end
