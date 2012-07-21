class DaBomb < Sinatra::Base
  post '/player' do
    if params[:username].blank?
      status 400
      return Yajl::Encoder.encode({:error => "Please, provide a username"})
    end

    player = Player.new({:username => params[:username]})
  end
end
