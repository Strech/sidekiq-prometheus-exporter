FROM ruby:2.3.6-alpine

RUN gem install sidekiq -v "~> 5.0"
ENTRYPOINT [ "sidekiq" ]
CMD [ "-r", "/sidekiq.rb", "-C", "/sidekiq.yml" ]
