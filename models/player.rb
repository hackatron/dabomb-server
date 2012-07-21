class Player < Hashie::Dash
  include BombStore::Connection
  extend BombStore::Connection

  property :username, :required => true

  def self.next
    famous = famous_bombers
    famous[rand(famous.size)].tr(' ', '_') + redis.incr('players_count').to_s
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
      Leaderboard.award_player(self, 0)
    else
      raise 'E.01'
    end
  end

  def retire
    if current_match
      current_match.cancel
    end

    redis.lrem(Match.waiting_key, 1, username)
  end

  def pair
    match = Match.new(self)
    if match.pal
      match.pal.wake_up(match.code)
      match.code
    else
      nil
    end
  end

  def wake_up(code)
    Pusher["dabomb-#{username}"].trigger('wake-up', {:code => code})
  end

  def current_match
    Match.from_code(redis.get("#{username}:match"))
  end

  def close_match(match, winner)
    Pusher["dabomb-#{username}"].trigger('close-match', {:winner => winner})
  end

  def notify_cancel
    Pusher["dabomb-#{username}"].trigger('match-cancel', {:boom => 'match cancel'})
  end
end
