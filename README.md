[![Build Status](https://travis-ci.org/Strech/sidekiq-prometheus-exporter.svg?branch=master)](https://travis-ci.org/Strech/sidekiq-prometheus-exporter)
[![Maintainability](https://api.codeclimate.com/v1/badges/bb1b30cd7aca8ecc9413/maintainability)](https://codeclimate.com/github/Strech/sidekiq-prometheus-exporter/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/bb1b30cd7aca8ecc9413/test_coverage)](https://codeclimate.com/github/Strech/sidekiq-prometheus-exporter/test_coverage)

# Sidekiq Prometheus Exporter

> — Hey! Sidekiq dashboard stats looks like a Prometheus metrics!?
>
> — Indeed ... :thinking:

![Grafana dashboard example](/examples/screenshot.png)

Open [dashboard example file](/examples/sidekiq.json), then open `https://<your grafana-url>/dashboard/import` and paste the content of the file.

# Available metrics

(starting Sidekiq `v3.3.1`)

```text
sidekiq_processed_jobs_total               counter  The total number of processed jobs.
sidekiq_failed_jobs_total                  counter  The total number of failed jobs.
sidekiq_busy_workers                       gauge    The number of workers performing the job.
sidekiq_enqueued_jobs                      gauge    The number of enqueued jobs.
sidekiq_scheduled_jobs                     gauge    The number of jobs scheduled for a future execution.
sidekiq_retry_jobs                         gauge    The number of jobs scheduled for the next try.
sidekiq_dead_jobs                          gauge    The number of jobs being dead.
sidekiq_queue_latency_seconds              gauge    The amount of seconds between oldest job being pushed
                                                    to the queue and current time (labels: name).
sidekiq_queue_max_processing_time_seconds  gauge    The amount of seconds between oldest job of the queue
                                                    being executed and current time (labels: name).
sidekiq_queue_enqueued_jobs                gauge    The number of enqueued jobs in the queue (labels: name).
```

# Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-prometheus-exporter'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install sidekiq-prometheus-exporter -v '~> 0.1'
```

# Rack application

For  a fresh new application to expose metrics create `config.ru` file with
next code inside

```ruby
require 'sidekiq'
require 'sidekiq/prometheus/exporter'

Sidekiq.configure_client do |config|
  config.redis = {url: 'redis://<your-redis-host>:6379/0'}
end

run Sidekiq::Prometheus::Exporter.to_app
```

Use your favorite server to start it up, like this

```bash
$ bundle exec rackup -p9292 -o0.0.0.0
```

and then `curl https://0.0.0.0:9292/metrics`

# Sidekiq Web (extream)

If you are ok with metrics being exposed via Sidekiq web dashboard because
you have it inside your private network or only Prometheus scraper will have access
to a machine/port/etc, then add a few lines into your web `config.ru`

```ruby
require 'sidekiq/web'
require 'sidekiq/prometheus/exporter'

Sidekiq::Web.register(Sidekiq::Prometheus::Exporter)
```

and then `curl https://<your-sidekiq-web-uri>/metrics`

# Sidekiq Contribs

By default we try to detect as many as possible sidekiq contribs and add their
metrics to the output. But you can change this behaviour by configuring
exporters setting

```ruby
require 'sidekiq/prometheus/exporter'

# Keep the default auto-detect behaviour
Sidekiq::Prometheus::Exporter.configure do |config|
  config.exporters = :auto_detect
end

# Keep only standard (by default) and cron metrics
Sidekiq::Prometheus::Exporter.configure do |config|
  config.exporters = %i(cron)
end
```

The list of available contrib exporters

* [cron](https://github.com/ondrejbartas/sidekiq-cron)

## Contributing

Bug reports and pull requests to support earlier versions of Sidekiq are welcome on GitHub at https://github.com/Strech/sidekiq-prometheus-exporter/issues.

# License

Please see [LICENSE](https://github.com/mperham/sidekiq/blob/master/LICENSE) for licensing details.
