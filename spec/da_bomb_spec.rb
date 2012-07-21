require 'spec_helper'

describe DaBomb do
  describe 'POST /players' do
    it 'respond with username' do
      post '/players'

      last_response.status.should == 201
      Yajl::Parser.parse(last_response.body).keys.should include('username')
    end
  end

  describe 'POST /players/:username/retire' do
    it 'remove respond success and remove player from match' do
      Player.any_instance.should_receive(:retire).with('username')

      post '/players/username/retire'

      last_response.status.should == 204
    end
  end

  describe 'POST /play/:username' do
    context 'waiting user' do
      before { Player.any_instance.stub(:paid).and_return(nil) }

      it 'respond success' do
        post '/play/username'

        last_response.should be_ok
        Yajl::Parser.parse(last_response.body).should == {'code' => nil}
      end
    end

    context 'pairing user' do
      before { Player.any_instance.stub(:pair).and_return('match_code') }

      it 'respond with match code' do
        post '/play/username'

        last_response.should be_ok
        Yajl::Parser.parse(last_response.body).should == {'code' => 'match_code'}
      end
    end
  end

  describe 'POST /defuse/:code' do
    context 'with valid params' do
      before { @match = match = Object.new }

      it 'respond success' do
        Match.stub(:from_code).and_return(@match)
        @match.stub(:defuse)

        post '/defuse/match_code', {:username => 'username', :time => '1.0'}

        last_response.status.should == 204
      end

      it 'set player time for match' do
        Match.should_receive(:from_code).with('match_code').and_return(@match)
        @match.should_receive(:defuse).with('username', '1.0')

        post '/defuse/match_code', {:username => 'username', :time => '1.0'}
      end
    end

    context 'with invalid params' do
      it 'respond bad request and error code E.02' do
        post 'defuse/match_code'

        last_response.should be_bad_request
        Yajl::Parser.parse(last_response.body)['error_code'].should == 'E.02'
      end
    end
  end
end