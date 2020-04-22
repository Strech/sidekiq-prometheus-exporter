FROM ruby:2.7-alpine

WORKDIR /usr/app

RUN gem install sidekiq-prometheus-exporter -v '~> 0.1'

COPY config.ru .

EXPOSE 9292

ENTRYPOINT ["sh", "-c", "rackup -p9292 -o0.0.0.0"]
