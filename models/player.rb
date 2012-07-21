class Player < Hashie::Dash
  include BombStore::Connection
  property :username, :required => true

  def self.next
    famuos = famous_bombers
    famous[famous.size] + redis.incr('players_count').to_s
  end

  def self.famous_bombers
    ['Fermi', 'Tom Jones', 'H-Bomb', 'Martin Riggs', 'Roger Murtaugh']
  end

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
