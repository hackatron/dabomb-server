class DaBomb < Sinatra::Base
  before do
    content_type 'application/json'
  end

  post '/player' do
    player = Player.new({:username => Player.next})
    player.register

    status 201
    return Yajl::Encoder.encode({:username => player.username})
  end

  post '/play/:username' do |username|
    player = Player.new({:username => username})

    status 200
    return Yajl::Encoder.encode({:code => player.pair})
  end

  post '/score/:username' do |username|
    code = params[:code]
    score = params[:score]

    if code.blank? || score.blank?
      status 400
      return Yajl::Encoder.encode({:error => 'Please, provide the match code and the player score', :error_code => 'E.02'})
    end

    match = Match.from_code(code)
    match.score(username, score)

    status 204
  end
end
