FROM ruby:3.4.2-alpine3.21

LABEL maintainer="Sergey Fedorov <oni.strech@gmail.com>"
LABEL repository="strech/sidekiq-prometheus-exporter"

ENV RACK_VERSION=3.1.12
ENV RACKUP_VERSION=2.2.1
ENV WEBRICK_VERSION=1.9.1
ENV SIDEKIQ_VERSION=8.0.2
ENV REDIS_NAMESPACE_VERSION=1.11.0
ENV SIDEKIQ_PROMETHEUS_EXPORTER_VERSION=0.3.0

RUN    addgroup -S exporter \
    && adduser -s /bin/false -SDHg exporter exporter \
    && gem install \
           "rack:$RACK_VERSION" \
           "rackup:$RACKUP_VERSION" \
           "webrick:$WEBRICK_VERSION" \
           "sidekiq:$SIDEKIQ_VERSION" \
           "redis-namespace:$REDIS_NAMESPACE_VERSION" \
           "sidekiq-prometheus-exporter:$SIDEKIQ_PROMETHEUS_EXPORTER_VERSION"

USER exporter
WORKDIR /app
COPY config.ru config.ru

EXPOSE 9292
ENTRYPOINT [ "rackup" ]
CMD [ "-E", "production", "-p", "9292", "-o", "0.0.0.0", "config.ru" ]
