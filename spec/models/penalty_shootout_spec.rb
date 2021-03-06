# frozen_string_literal: true

# == Schema Information
#
# Table name: penalty_shootouts
#
#  id         :bigint           not null, primary key
#  away_score :integer
#  home_score :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_id   :bigint
#
# Indexes
#
#  index_penalty_shootouts_on_match_id  (match_id)
#

require 'rails_helper'

RSpec.describe PenaltyShootout, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:penalty_shootout)).to be_valid
  end

  it 'requires a home score' do
    expect(FactoryBot.build(:penalty_shootout, home_score: nil)).to_not be_valid
  end

  it 'requires an away score' do
    expect(FactoryBot.build(:penalty_shootout, away_score: nil)).to_not be_valid
  end

  it 'must have a winner' do
    score = Faker::Number.between(from: 0, to: 20)
    expect(
      FactoryBot.build(:penalty_shootout, home_score: score, away_score: score)
    ).to_not be_valid
  end

  it 'can only be created for drawn ties' do
    @match = FactoryBot.create :match
    @player = FactoryBot.create :player, team: @match.team
    FactoryBot.create :cap, match: @match, player: @player
    FactoryBot.create :goal, match: @match, player: @player
    expect(FactoryBot.build(:penalty_shootout, match: @match)).to_not be_valid
  end
end
