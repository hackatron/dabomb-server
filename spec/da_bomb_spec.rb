require 'spec_helper'

describe DaBomb do
  describe '/player' do
    it 'respond with username' do
      post '/player'

      last_response.should be_ok
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
end