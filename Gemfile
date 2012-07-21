source 'http://rubygems.org'
gem 'rake', '0.8.7'

gem 'sinatra', :git => 'git://github.com/sinatra/sinatra.git'
gem 'yajl-ruby', :require => 'yajl'

gem 'hiredis'
gem 'redis', '~> 2.2.0', :require => ['redis', 'redis/connection/hiredis']

gem 'pusher'

gem 'hashie'

gem 'thin'

group :development do
  gem 'heroku'
  gem 'foreman'
end

group :test do
  gem 'rspec'
  gem 'rack-test', :require => 'rack/test'
  gem 'debugger'
end
