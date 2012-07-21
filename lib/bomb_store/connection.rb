module BombStore
  module Connection
    def redis
      BombStore::Redis.redis
    end
  end
end
