class Player < Hashie::Dash
  include BombStore::Connection
  property :username, :required => true

  def key
    'players:' + username
  end

  def unique?
    redis.sadd('players', username)
  end

  def register
    if unique?
      redis.hset(key, 'username', username)
    else
      raise 'E.01'
    end
  end

  def pair
    match = Match.new(self)
    if match.pal
      pal.wake_up(match.code)
      match.code
    else
      nil
    end
  end

  def wake_up(code)
    # TODO
  end
end
