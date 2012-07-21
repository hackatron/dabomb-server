class Match
  include BombStore::Connection
  attr_reader :pal

  def initialize(player, pal = nil, code = nil)
    @player = player
    @pal = pal
    @code = code
    if @pal.nil?
      pair
    end
  end

  def self.from_code(code)
    players = redis.get("pairs:#{code}")
    players = players.split(":").collect {|p| Player.new({:username => p})}
    Match.new(*players)
  end

  def pair
    r = redis
    begin
      @pal = Player.new({:username => r.lpop})
    rescue
      wait
      return
    end

    r.set(code, "#{@player.username}:#{@pal.username}")
  end

  def code
    sha256 = Digest::SHA256.new
    players = "#{@player.username}:#{@pal.username}"
    @code = sha256.digest(players)
  end

  def wait
    redis.rpush(self.class.waiting_key, @player.username)
    @pal = nil
  end

  def play
    [@player, @pal].each {|p| p.start_match(self)}
  end

  def score_key
    "#{code}:score"
  end

  def score(who, score)
    field_key = 'pal'
    if is_player?(who)
      field_key = 'player'
    end

    BombStore.hset(score_key, field_key, score)

    score = BombStore.hgetall
    if score.keys.size == 2
      find_winner(score)
    end
  end

  def find_winner(score)
    winner = score[@player.username] > score[@pal.username] ? @player : @pal
    [@player, @pal].each {|p| p.close_match(self, winner)}

    # the match is over, remove match keys
    BombStore.del(score_key)
    BombStore.del(code)
  end

  def self.waiting_key
    'waiting.pair'
  end

  def self.waiting_list
    BombStore.rlindex(waiting_key, 0, -1)
  end
end
