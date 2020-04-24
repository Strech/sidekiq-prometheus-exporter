FROM ruby:2.7.1-alpine

LABEL maintainer="Sergey Fedorov <oni.strech@gmail.com>"
LABEL repository="strech/sidekiq-prometheus-exporter"

ENV RACK_VERSION 2.0.9
ENV SIDEKIQ_VERSION 5.2.8
ENV REDIS_NAMESPACE_VERSION 1.7.0
ENV SIDEKIQ_PROMETHEUS_EXPORTER_VERSION 0.1.13

RUN    gem install "rack:$RACK_VERSION" \
    && gem install "sidekiq:$SIDEKIQ_VERSION" \
    && gem install "redis-namespace:$REDIS_NAMESPACE_VERSION" \
    && gem install "sidekiq-prometheus-exporter:$SIDEKIQ_PROMETHEUS_EXPORTER_VERSION"

USER nobody
WORKDIR /app
COPY config.ru config.ru

EXPOSE 9292
ENTRYPOINT [ "rackup" ]
CMD [ "-p", "9292", "-o", "0.0.0.0", "config.ru" ]
