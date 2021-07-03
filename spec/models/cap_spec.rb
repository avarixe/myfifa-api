# frozen_string_literal: true
# == Schema Information
#
# Table name: caps
#
#  id         :bigint           not null, primary key
#  pos        :string
#  rating     :integer
#  start      :integer          default(0)
#  stop       :integer          default(90)
#  subbed_out :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_id   :bigint
#  player_id  :bigint
#
# Indexes
#
#  index_caps_on_match_id                    (match_id)
#  index_caps_on_player_id                   (player_id)
#  index_caps_on_player_id_and_match_id      (player_id,match_id) UNIQUE
#  index_caps_on_pos_and_match_id_and_start  (pos,match_id,start) UNIQUE
#

require 'rails_helper'

RSpec.describe Cap, type: :model do
  before do |test|
    unless test.metadata[:skip_before]
      @team = FactoryBot.create :team
      @player = FactoryBot.create :player, team: @team
      @match = FactoryBot.create :match, team: @team
      @cap = FactoryBot.create :cap, player: @player, match: @match
    end
  end

  it 'has a valid factory', skip_before: true do
    expect(FactoryBot.create(:cap)).to be_valid
  end

  it 'requires a position', skip_before: true do
    expect(FactoryBot.build(:cap, pos: nil)).to_not be_valid
  end

  it 'requires a player', skip_before: true do
    expect(FactoryBot.build(:cap, player_id: nil)).to_not be_valid
  end

  it 'requires a start minute', skip_before: true do
    expect(FactoryBot.build(:cap, start: nil)).to_not be_valid
  end

  it 'requires a stop minute', skip_before: true do
    expect(FactoryBot.build(:cap, stop: nil)).to_not be_valid
  end

  it 'requires a valid rating if any', skip_before: true do
    expect(FactoryBot.build(:cap, rating: 0)).to_not be_valid
    expect(FactoryBot.build(:cap, rating: 6)).to_not be_valid
  end

  it 'can not have a stop minute before the start minute' do
    expect(FactoryBot.build(:cap, start: 46, stop: 45)).to_not be_valid
  end

  it 'only accepts Active players' do
    @player = FactoryBot.create :player, contracts_count: 0
    expect(FactoryBot.build(:cap, player: @player)).to_not be_valid
  end

  it 'must be associated with a Player and Match of the same team' do
    @other_team = FactoryBot.create :team
    @match = FactoryBot.create :match, team: @other_team
    expect(FactoryBot.build(:cap, player: @player, match: @match)).to_not be_valid
  end

  it 'removes all Match events concerning the player upon destruction' do
    FactoryBot.create :goal,
                      match: @match,
                      player: @player
    FactoryBot.create :goal,
                      match: @match,
                      assisting_player: @player
    FactoryBot.create :booking,
                      match: @match,
                      player: @player
    # FactoryBot.create :substitution,
    #                   match: @match,
    #                   player: @player
    # FactoryBot.create :substitution,
    #                   match: @match,
    #                   replacement: @player
  end

end
