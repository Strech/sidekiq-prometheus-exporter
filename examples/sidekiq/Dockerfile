FROM ruby:3.4.2-alpine3.21

RUN gem install base64 -v "0.2.0"
RUN gem install sidekiq -v "~> 5.0"

ENTRYPOINT [ "sidekiq" ]
CMD [ "-r", "/sidekiq.rb", "-C", "/sidekiq.yml" ]
