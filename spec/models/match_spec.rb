require 'spec_helper'

describe Match do
  before(:all) do
    @pal = Player.new(:username => 'pal')
    @pal.register

    @player = Player.new(:username => 'player')
    @player.register
  end

  describe 'Pair players' do
    context 'when a user asks to play' do
      before(:all) do
        @match = Match.new(@pal)
      end

      subject { Match.waiting_list }

      it { should include(@pal.username) }
    end

    context 'when a second user asks to play' do
      before(:all) do
        @match = Match.new(@player)
      end

      subject { @match }

      its(:pal) { should == @pal }
      its(:code) { should_not be_nil }
      it { Match.waiting_list.should == [] }
    end
  end

  describe 'Defuse dabomb' do
    before(:all) do
      Match.new(@pal)
      @match = Match.new(@player, @pal)
    end

    context 'when player defuse dabomb' do
      before(:all) do
        @match.defuse(@player, 10)
      end

      it 'should register time for player' do
        time_hash = @match.redis.hgetall(@match.time_key)
        time_hash['player'].to_i.should == 10
        time_hash.keys.size.should == 1
      end
    end

    context 'when pal defuse dabomb' do
      before(:all) do
        @match.defuse(@pal, 9)
      end

      subject { @match }

      its(:winner) { should == @pal }
    end
  end
end
