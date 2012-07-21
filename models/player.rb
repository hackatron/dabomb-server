class Player < Hashie::Dash
  include BombStore::Connection
  extend BombStore::Connection

  property :username, :required => true

  def self.next
    famous = famous_bombers
    famous[rand(famous.size)].tr(' ', '_') + redis.incr('players_count').to_s
  end

  def self.famous_bombers
    [
      'Enrico Fermi',         # atomic bomb
      'Tom Jones',            # sexy bomb
      'H-Bomb',               # h(farm)/h(ydrogen)
      'Martin Riggs',         # lethal weapon
      'Roger Murtaugh',       # lethal weapon
      'Ascanio Sobrero',      # nitroglycerin
      'Christian Schonbein',  # nitrocellulose
      'Joseph Wilbrand',      # TNT
      'Albert Nobel',         # dynamite
      'Ted Kaczynski',        # unabomber
      'Elvo Zornitta'         # italian unabomber
    ]
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
    else
      notify_cancel
    end

    redis.lrem(Match.waiting_key, 1, username)
  end

  def defer_retirement
    puts "defer_retirement: #{username}"

    # defer player retirement after 30 seconds of inactivity
    begin
      retire_timer = EM::Timer.new(30) { retire }
      redis.set("retire_timer:#{username}", Marshal.dump(retire_timer))
    rescue
      # ...
    end
  end

  def cancel_retirement
    puts "cancel_retirement: #{username}"

    if retire_timer = redis.get("retire_timer:#{username}")
      Marshal.load(retire_timer).cancel
      redis.del("retire_timer:#{username}")
    end
  end

  def pair
    match = Match.new(self)
    if match.pal
      match.pal.cancel_retirement
      match.pal.wake_up(match.code)
      match.code
    else
      defer_retirement
      nil
    end
  end

  def current_match
    Match.from_code(redis.get("#{username}:match"))
  end

  def channel
    Pusher["dabomb-#{username}"]
  end

  def wake_up(code)
    channel.trigger('wake-up', {:code => code})
  end

  def close_match(match, winner)
    channel.trigger('close-match', {:winner => winner.username})
  end

  def notify_cancel
    puts "notify_cancel: #{username}"
    
    channel.trigger('match-cancel', {:boom => 'match cancel'})
  end
end
