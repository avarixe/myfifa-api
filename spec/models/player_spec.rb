# == Schema Information
#
# Table name: players
#
#  id          :bigint(8)        not null, primary key
#  team_id     :bigint(8)
#  name        :string
#  nationality :string
#  pos         :string
#  sec_pos     :text             default([]), is an Array
#  ovr         :integer
#  value       :integer
#  birth_year  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string
#  youth       :boolean          default(TRUE)
#  kit_no      :integer
#
# Indexes
#
#  index_players_on_team_id  (team_id)
#

require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:player) { FactoryBot.create(:player) }

  it "has a valid factory" do
    expect(player).to be_valid
  end
  
  it 'requires a name' do
    expect(FactoryBot.build(:player, name: nil)).to_not be_valid
  end
    
  it 'requires a valid position' do
    expect(FactoryBot.build(:player, pos: nil)).to_not be_valid
    expect(FactoryBot.build(:player, pos: 'GKK')).to_not be_valid
  end
  
  it 'requires an valid OVR' do
    expect(FactoryBot.build(:player, ovr: nil)).to_not be_valid
    expect(FactoryBot.build(:player, ovr: -1)).to_not be_valid
  end
  
  it 'requires a valid value' do
    expect(FactoryBot.build(:player, value: nil)).to_not be_valid
    expect(FactoryBot.build(:player, value: -1)).to_not be_valid
  end
  
  it 'requires a birth year' do
    expect(FactoryBot.build(:player, birth_year: nil)).to_not be_valid
    expect(FactoryBot.build(:player, value: -1)).to_not be_valid
  end

  it 'requires all secondary positions to be valid' do
    sec_pos = []
    3.times do
      sec_pos << Player::POSITIONS.sample
    end
    expect(FactoryBot.build(:player, sec_pos: [''])).to_not be_valid
    expect(FactoryBot.build(:player, sec_pos: sec_pos)).to be_valid
  end

  it 'starts with a history record' do
    expect(player.player_histories.length).to be == 1
  end

  it 'records attribute changes in history' do
    player.team.increment_date(1.day)

    player.ovr += 1
    player.save!
    player.player_histories.reload
    expect(player.player_histories.length).to be == 2
    expect(player.player_histories.last.ovr).to be == player.ovr

    player.value += 1_000_000
    player.save!
    player.player_histories.reload
    expect(player.player_histories.length).to be == 2
    expect(player.player_histories.last.value).to be == player.value
  end 
end
