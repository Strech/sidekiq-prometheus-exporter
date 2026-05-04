# Architecture

Ruby gem + Docker image + Helm chart. Gem is the core product, Docker wraps it as standalone Rack app, Helm deploys the Docker image to Kubernetes.

## Gem

Rack app that scrapes Sidekiq internals and renders Prometheus text format via ERB templates.

- Entry point: `lib/sidekiq/prometheus/exporter.rb` — Rack `call` interface, also mounts into Sidekiq::Web
- Exporters: standard (always on), cron (sidekiq-cron), scheduler (sidekiq-scheduler) — auto-detected via `available?`
- Metrics output: ERB templates in `lib/sidekiq/prometheus/exporter/templates/`
- Multi-version support: Appraisal gemfiles for Sidekiq 4.x through 8.x+latest, Rakefile picks spec directory by Sidekiq version

## Versioning

- `VERSION` in `lib/sidekiq/prometheus/exporter/version.rb` — gem, Docker base, Helm appVersion
- `DOCKER_PATCH_VERSION` — bumped for Docker-only changes, resets on VERSION bump
- Helm chart `version` uses `-X` suffix for chart-only changes (e.g. `0.3.1-1`)

## Commands

- `bundle exec rake spec` — run specs (auto-selects spec dir by Sidekiq version)
- `bundle exec rake docker:release` — build+push multi-arch Docker image
- `bundle exec rake helm:generate` — package chart and regenerate index.yaml
