FROM ruby:2.3.6-alpine

RUN gem install sidekiq -v "~> 5.0"
RUN gem install sidekiq-prometheus-exporter -v "~> 0.1"

ENTRYPOINT [ "rackup" ]
CMD [ "-p", "9292", "-o", "0.0.0.0", "/config.ru" ]
