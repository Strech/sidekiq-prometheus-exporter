FROM ruby:3.2.2-alpine3.16

LABEL maintainer="Sergey Fedorov <oni.strech@gmail.com>"
LABEL repository="strech/sidekiq-prometheus-exporter"

ENV RACK_VERSION=2.2.7
ENV WEBRICK_VERSION=1.8.1
ENV SIDEKIQ_VERSION=6.5.9
ENV REDIS_NAMESPACE_VERSION=1.11.0
ENV SIDEKIQ_PROMETHEUS_EXPORTER_VERSION=0.2.0

RUN    addgroup -S exporter \
    && adduser -s /bin/false -SDHg exporter exporter \
    && gem install "rack:$RACK_VERSION" \
    && gem install "webrick:$WEBRICK_VERSION" \
    && gem install "sidekiq:$SIDEKIQ_VERSION" \
    && gem install "redis-namespace:$REDIS_NAMESPACE_VERSION" \
    && gem install "sidekiq-prometheus-exporter:$SIDEKIQ_PROMETHEUS_EXPORTER_VERSION"

USER exporter
WORKDIR /app
COPY config.ru config.ru

EXPOSE 9292
ENTRYPOINT [ "rackup" ]
CMD [ "-E", "production", "-p", "9292", "-o", "0.0.0.0", "config.ru" ]
