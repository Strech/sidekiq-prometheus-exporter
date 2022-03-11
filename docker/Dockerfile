FROM ruby:2.7.5-alpine

LABEL maintainer="Sergey Fedorov <oni.strech@gmail.com>"
LABEL repository="strech/sidekiq-prometheus-exporter"

ENV RACK_VERSION 2.0.9
ENV SIDEKIQ_VERSION 6.2.1
ENV REDIS_NAMESPACE_VERSION 1.8.1
ENV SIDEKIQ_PROMETHEUS_EXPORTER_VERSION 0.1.17

RUN    addgroup -S exporter \
    && adduser -s /bin/false -SDHg exporter exporter \
    && gem install "rack:$RACK_VERSION" \
    && gem install "sidekiq:$SIDEKIQ_VERSION" \
    && gem install "redis-namespace:$REDIS_NAMESPACE_VERSION" \
    && gem install "sidekiq-prometheus-exporter:$SIDEKIQ_PROMETHEUS_EXPORTER_VERSION"

USER exporter
WORKDIR /app
COPY config.ru config.ru

EXPOSE 9292
ENTRYPOINT [ "rackup" ]
CMD [ "-p", "9292", "-o", "0.0.0.0", "config.ru" ]
