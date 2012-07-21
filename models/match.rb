class Match
  include BombStore::Connection
  extend BombStore::Connection
  
  attr_reader :pal, :winner

  def initialize(player, pal = nil)
    @player = player
    @pal = pal
    if @pal.nil?
      pair
    end
  end

  def self.from_code(code)
    players = redis.get("pairs:#{code}")
    begin
      players = players.split(":").collect {|p| Player.new({:username => p})}
      Match.new(*players)
    rescue
      nil
    end
  end

  def pair
    r = redis
    begin
      @pal = Player.new({:username => r.lpop(self.class.waiting_key)})
    rescue
      wait
      return
    end

    r.set("pairs:#{code}", "#{@player.username}:#{@pal.username}")
    r.set("#{@pal.username}:match", code)
  end

  def code
    players = "#{@player.username}:#{@pal.username}"
    Digest::SHA1.hexdigest(players)
  end

  def wait
    redis.rpush(self.class.waiting_key, @player.username)
    @pal = nil
  end

  def play
    [@player, @pal].each {|p| p.start_match(self)}
  end

  def time_key
    "#{code}:time"
  end

  def defuse(who, time)
    field_key = 'pal'
    if is_player?(who)
      field_key = 'player'
    end

    redis.hset(time_key, field_key, time)

    time = redis.hgetall(time_key)
    if time.keys.size == 2
      find_winner(time)
    end
  end

  def cancel
    @player.notify_cancel
    destroy
  end

  def is_player?(who)
    @player == who
  end

  def find_winner(time)
    @winner = time[@player.username].to_i > time[@pal.username].to_i ? @pal : @player
    if time[@winner.username].to_i == -1
      @winner = nil
    end

    [@player, @pal].each {|p| p.close_match(self, @winner)}

    if @winner
      Leaderboard.award_player(@winner, 1)
    end

    # the match is over, remove match keys
    destroy
  end

  def destroy
    redis.del(time_key)
    redis.del(code)
  end

  def self.waiting_key
    'waiting.pair'
  end

  def self.waiting_list
    redis.lrange(waiting_key, 0, -1)
  end
end
