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
end
