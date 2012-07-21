require 'spec_helper'

describe DaBomb do
  describe '/player' do
    it 'respond with username' do
      post '/player'

      last_response.status.should == 201
      Yajl::Parser.parse(last_response.body).keys.should include('username')
    end
  end

  describe '/play/:username' do
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

  describe '/score/:username' do
    context 'with valid params' do
      it 'respond success' do
        post '/score/username', {:code => 'code', :score => 1.0}

        last_response.should be_success
      end

      it 'set player score for match' do
        match = Object.new
        Match.should_receive(:from_code).with(@code).and_return(match)
        match.should_receive(:score).with('username', '1.0')

        post '/score/username', {:code => 'code', :score => '1.0'}
      end
    end

    context 'with invalid params' do
      it 'respond bad request and error code E.02' do
        post 'score/username'

        last_response.should be_bad_request
        Yajl::Parser.parse(last_response.body)['error_code'].should == 'E.02'
      end
    end
  end
end