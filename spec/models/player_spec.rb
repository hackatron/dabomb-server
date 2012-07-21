require 'spec_helper'

describe Player do
  before(:all) { @player = Player.new(:username => 'username') }

  describe 'register' do
    context 'when username is not unique' do
      before { @player.stub(:unique?).and_return(false) }

      it 'should raise exception' do
        lambda { @player.register }.should raise_error
      end
    end

    context 'when username is unique' do
      before { @player.stub(:unique?).and_return(true) }

      it 'set player hash' do
        @player.register
        @player.redis.hget(@player.key, 'username').should == @player.username
      end
    end
  end

  describe 'retire' do
    before do
      @match = Match.new(@player)
      @player.stub(:current_match).and_return(@match)
    end

    it 'cancel current_match and remove user from waiting list' do
      @match.should_receive(:cancel)
      @player.retire
      @player.redis.lindex(Match.waiting_key, @player.username).should be_nil
    end
  end

  describe 'pair' do
    it 'create a new match' do
      @player.pair.should be_nil
    end

    context 'with pal waiting' do
      before do
        @pal = Player.new(:username => 'pal')
      end

      it 'should wake up pal'

      it 'return match code' do
        @pal.pair.should == Match.new(@pal, @player).code
      end
    end
  end
end