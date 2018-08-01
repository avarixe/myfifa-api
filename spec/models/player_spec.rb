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
  let(:contracted_player) { FactoryBot.create(:contracted_player)}

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

  it 'starts with a history record' do
    expect(player.player_histories.length).to be == 1
  end

  it 'records attribute changes in history' do
    player.ovr += 1
    player.save!
    expect(player.player_histories.length).to be == 2
    expect(player.player_histories.last.ovr).to be == player.ovr

    player.value += 1_000_000
    player.save!
    expect(player.player_histories.last.value).to be == player.value
  end 

  it 'is eligible to play after signing a new contract' do
    player.contracts.create(FactoryBot.attributes_for(:contract))
    expect(player.active?).to be true
  end

  it 'is not eligible to play if contract expires' do
    contracted_player.contracts.last.update(end_date: 1.day.from_now)
    contracted_player.team.increment_date(1.week)
    contracted_player.reload
    expect(contracted_player.active?).to be_falsey
  end
end
