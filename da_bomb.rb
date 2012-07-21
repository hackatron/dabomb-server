Encoding.default_external = Encoding::UTF_8

class DaBomb < Sinatra::Base
  VERSION = '0.0.6'

  before do
    content_type 'application/json'
  end

  post '/players' do
    player = Player.new(:username => Player.next)
    player.register

    status 201
    return Yajl::Encoder.encode({:username => player.username})
  end

  post '/players/:username/retire' do |username|
    player = Player.new(:username => username)
    player.retire

    status 204
  end

  post '/play/:username' do |username|
    player = Player.new({:username => username})

    status 200
    return Yajl::Encoder.encode({:code => player.pair})
  end

  post '/defuse/:code' do |code|
    username = params[:username]
    time = params[:time]

    if username.blank? || time.blank?
      status 400
      return Yajl::Encoder.encode({:error => 'Please, provide player username and defuse time', :error_code => 'E.02'})
    end

    match = Match.from_code(code)
    match.defuse(Player.new(:username => username), time)

    status 204
  end

  get '/leaderboard' do
    leaders = Leaderboard.top
    
    status 200
    Yajl::Encoder.encode(leaders)
  end
end
