appraise 'sidekiq-4.1.0' do
  gem 'redis', '~> 3.3'
  gem 'sidekiq', '= 4.1.0'
  gem 'sinatra'
end

appraise 'sidekiq-4.x' do
  gem 'redis', '~> 3.3'
  gem 'sidekiq', '~> 4.1'
end

appraise 'sidekiq-5.x' do
  gem 'redis', '~> 3.3'
  gem 'sidekiq', '~> 5.0'
end

appraise 'sidekiq-6.x' do
  gem 'base64'
  gem 'redis', '~> 4.1'
  gem 'sidekiq', '~> 6.0'
end

appraise 'sidekiq-7.x' do
  gem 'redis', '~> 5.0'
  gem 'sidekiq', '~> 7.0'
end

appraise 'sidekiq-latest' do
  gem 'base64'
  gem 'redis', '>= 4', github: 'redis/redis-rb'
  gem 'sidekiq', '>= 7', github: 'mperham/sidekiq'
end
