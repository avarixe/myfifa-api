# frozen_string_literal: true

# == Schema Information
#
# Table name: goals
#
#  id          :bigint(8)        not null, primary key
#  match_id    :bigint(8)
#  minute      :integer
#  player_name :string
#  player_id   :bigint(8)
#  assist_id   :bigint(8)
#  home        :boolean          default(FALSE)
#  own_goal    :boolean          default(FALSE)
#  penalty     :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  assisted_by :string
#
# Indexes
#
#  index_goals_on_assist_id  (assist_id)
#  index_goals_on_match_id   (match_id)
#  index_goals_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Goal, type: :model do
  let(:goal) { FactoryBot.create(:goal) }

  it "has a valid factory" do
    expect(goal).to be_valid
  end

  it 'requires a valid minute' do
    expect(FactoryBot.build(:goal, minute: nil)).to_not be_valid
    expect(FactoryBot.build(:goal, minute: -1)).to_not be_valid
  end

  it 'requires a valid player name' do
    expect(FactoryBot.build(:goal, player_name: nil)).to_not be_valid
  end

  it 'increments appropriate score' do
    @match = FactoryBot.create :match
    home_goal = FactoryBot.create :home_goal, match: @match
    expect(@match.score).to be == '1 - 0'

    FactoryBot.create :away_goal, match: @match
    expect(@match.score).to be == '1 - 1'
  end

  it 'increments opposite score if own goal' do
    @match = FactoryBot.create :match
    home_goal = FactoryBot.create :own_home_goal, match: @match
    expect(@match.score).to be == '0 - 1'

    FactoryBot.create :own_away_goal, match: @match
    expect(@match.score).to be == '1 - 1'
  end

  it 'automatically sets player name if player_id set' do
    player = FactoryBot.create :player
    player_goal = FactoryBot.create :goal, player_id: player.id
    expect(player_goal.player_name).to be == player.name
  end

  it 'changes player name if player_id changed' do
    player = FactoryBot.create :player
    player2 = FactoryBot.create :player, team: player.team
    player_goal = FactoryBot.create :goal, player_id: player.id
    player_goal.update(player_id: player2.id)
    expect(player_goal.player_name).to be == player2.name
  end

  it 'automatically sets assisted by if assist_id set' do
    player = FactoryBot.create :player
    player_assist = FactoryBot.create :goal, assist_id: player.id
    expect(player_assist.assisted_by).to be == player.name
  end

  it 'changes assisted by if assist_id changed' do
    player = FactoryBot.create :player
    player2 = FactoryBot.create :player, team: player.team
    player_assist = FactoryBot.create :goal, assist_id: player.id
    player_assist.update(assist_id: player2.id)
    expect(player_assist.assisted_by).to be == player2.name
  end

  it 'decrements score if goal is destroyed' do
    @match = FactoryBot.create :match
    goal = FactoryBot.create :home_goal, match: @match
    goal.destroy
    expect(@match.reload.score).to be == '0 - 0'
  end

  it 'changes score if home/away is toggled' do
    %i[home_goal away_goal own_home_goal own_away_goal].each do |goal_type|
      goal = FactoryBot.create goal_type
      score = goal.match.score
      goal.toggle(:home) && goal.save
      expect(goal.match.score).to be == score.reverse
      goal.toggle(:home) && goal.save
      expect(goal.match.score).to be == score
    end
  end

  it 'changes score if own_goal is toggled' do
    %i[home_goal away_goal own_home_goal own_away_goal].each do |goal_type|
      goal = FactoryBot.create goal_type
      score = goal.match.score
      goal.toggle(:own_goal) && goal.save
      expect(goal.match.score).to be == score.reverse
      goal.toggle(:own_goal) && goal.save
      expect(goal.match.score).to be == score
    end
  end

  it 'does not change score if home/away and own_goal is toggled' do
    %i[home_goal away_goal own_home_goal own_away_goal].each do |goal_type|
      goal = FactoryBot.create :home_goal
      score = goal.match.score
      goal.toggle(:home) && goal.toggle(:own_goal) && goal.save
      expect(goal.match.score).to be == score
    end
  end

end
