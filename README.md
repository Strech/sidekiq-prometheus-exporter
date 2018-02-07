# Sidekiq Prometheus Exporter

> — Hey! Sidekiq dashboard stats looks like a Prometheus metrics!?
>
> — Indeed ... :thinking:

# Sidekiq Web

If you are fine, that metrics will be exposed via Sidekiq web dashboard,
then add a few lines into your web `config.ru`

```ruby
require 'sidekiq/web'
require 'sidekiq/prometheus/exporter'
```

and then `curl https://<your-sidekiq-web>/metrics`

# Rack application

If you want to have a fresh new application to expose metrics, then please create `config.ru` that way

```ruby
require 'sidekiq/prometheus/exporter'
run Sidekiq::Prometheus::Exporter
```

use your favorite server to start it up or just

```
$ bundle exec rackup -p9292 -o0.0.0.0
```

and then `curl https://<your-sidekiq-web>/metrics`
