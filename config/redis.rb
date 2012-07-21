if ENV['REDISTOGO_URL']
  uri = URI.parse(ENV["REDISTOGO_URL"])
  redis_settings = {:host => uri.host, :port => uri.port, :password => uri.password}
  BombStore::Redis.redis = Redis.new(redis_settings)
else
  BombStore::Redis.redis = Redis.new
end
