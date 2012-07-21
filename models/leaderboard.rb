class Leaderboard
  extend BombStore::Connection

  def self.key
    "leaderboard"
  end

  def self.award_player(player, points)
    redis.zincrby(key, points, player.username)
  end

  def self.top(limit = 10)
    top = redis.zrevrange(key, 0, limit, :withscores => true)
    leaders = []
    top.each_with_index do |e, i|
      next if (i % 2) != 0
      leaders << {:username => e, :score => top[i + 1].to_i, :rank => (i/2) + 1}
    end

    leaders
  end
end
