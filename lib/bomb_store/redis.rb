module BombStore
  module Redis
    @redis = nil
    @config = {}

    def self.redis
      @redis ||= self.establish_connection
    end

    def self.redis=(redis)
      @redis = redis
    end

    def self.establish_connection
      ::Redis.new(@config)
    end

    def self.config=(config)
      @config = config
    end
  end
end
