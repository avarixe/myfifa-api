# == Schema Information
#
# Table name: performances
#
#  id         :bigint(8)        not null, primary key
#  match_id   :bigint(8)
#  player_id  :bigint(8)
#  pos        :string
#  start      :integer
#  stop       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  subbed_out :boolean          default(FALSE)
#  rating     :integer
#
# Indexes
#
#  index_performances_on_match_id   (match_id)
#  index_performances_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Performance, type: :model do
  before :each do |test|
    unless test.metadata[:skip_before]
      @team = FactoryBot.create :team
      @player = FactoryBot.create :player, team: @team
      @match = FactoryBot.create :match, team: @team
      @performance = FactoryBot.create :performance,
                                       player: @player,
                                       match: @match
    end
  end

  it 'has a valid factory', skip_before: true do
    expect(FactoryBot.create(:performance)).to be_valid
  end

  it 'requires a position', skip_before: true do
    expect(FactoryBot.build(:performance, pos: nil)).to_not be_valid
  end

  it 'requires a player', skip_before: true do
    expect(FactoryBot.build(:performance, player_id: nil)).to_not be_valid
  end

  it 'requires a start minute', skip_before: true do
    expect(FactoryBot.build(:performance, start: nil)).to_not be_valid
  end

  it 'requires a stop minute', skip_before: true do
    expect(FactoryBot.build(:performance, stop: nil)).to_not be_valid
  end

  it 'requires a valid rating if any', skip_before: true do
    expect(FactoryBot.build(:performance, rating: 0)).to_not be_valid
    expect(FactoryBot.build(:performance, rating: 6)).to_not be_valid
  end

  it 'can not have a stop minute before the start minute' do
    expect(FactoryBot.build(:performance, start: 46, stop: 45)).to_not be_valid
  end

  it 'only accepts Active players' do
    @player = FactoryBot.create :player, contracts_count: 0
    expect(FactoryBot.build(:performance, player: @player)).to_not be_valid
  end

  it 'must be associated with a Player and Match of the same team' do
    @other_team = FactoryBot.create :team
    @player = FactoryBot.create :player, team: @team
    @match = FactoryBot.create :match, team: @other_team
    expect(FactoryBot.build(:performance, player: @player, match: @match)).to_not be_valid
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
