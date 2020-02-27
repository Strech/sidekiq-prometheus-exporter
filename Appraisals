appraise 'sidekiq-3.3.1' do
  gem 'slim'
  gem 'redis', '~> 3.3'
  gem 'redis-namespace', '< 1.7.0'
  gem 'sinatra'
  gem 'concurrent-ruby'
  gem 'sidekiq', '= 3.3.1'
end

appraise 'sidekiq-3.x' do
  gem 'slim'
  gem 'redis', '~> 3.3'
  gem 'redis-namespace', '< 1.7.0'
  gem 'sinatra'
  gem 'concurrent-ruby'
  gem 'sidekiq', '~> 3.0'
end

appraise 'sidekiq-4.x' do
  gem 'redis', '~> 3.3'
  gem 'sidekiq', '~> 4.0'
end

appraise 'sidekiq-5.x' do
  gem 'redis', '~> 3.3'
  gem 'sidekiq', '~> 5.0'
end

appraise 'sidekiq-6.x' do
  gem 'redis', '~> 4.1'
  gem 'sidekiq', '~> 6.0'
end

appraise 'sidekiq-head' do
  gem 'rack', '>= 2', github: 'rack/rack'
  gem 'redis', '>= 4', github: 'redis/redis-rb'
  gem 'sidekiq', '>= 6', github: 'mperham/sidekiq'
end
