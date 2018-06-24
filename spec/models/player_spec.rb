# == Schema Information
#
# Table name: players
#
#  id          :integer          not null, primary key
#  team_id     :integer
#  name        :string
#  nationality :string
#  pos         :string
#  sec_pos     :text
#  ovr         :integer
#  value       :integer
#  age         :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string
#  youth       :boolean          default(TRUE)
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
  
  it 'requires a nationality' do
    expect(FactoryBot.build(:player, nationality: nil)).to_not be_valid
  end
  
  it 'requires a position' do
    expect(FactoryBot.build(:player, pos: nil)).to_not be_valid
  end
  
  it 'requires an overall rating' do
    expect(FactoryBot.build(:player, ovr: nil)).to_not be_valid
  end
  
  it 'requires a value' do
    expect(FactoryBot.build(:player, value: nil)).to_not be_valid
  end
  
  it 'requires an age' do
    expect(FactoryBot.build(:player, age: nil)).to_not be_valid
  end
  
  it 'has an initial contract' do
    expect(player.contracts.length).to be == 1
  end
  
  it 'records attribute changes in history' do
    player.update(age: player.age + 1)
    expect(player.player_histories.length).to be == 2
    expect(player.player_histories.last.age).to be == player.age

    player.update(ovr: Faker::Number.between(50, 90))
    expect(player.player_histories.last.ovr).to be == player.ovr

    player.update(value: Faker::Number.between(50_000, 200_000_000))
    expect(player.player_histories.last.value).to be == player.value
  end 
  
  it 'changes status to injured when injured' do
    player.injuries.create(FactoryBot.attributes_for(:injury))
    expect(player.status).to be == 'injured'
  end
  
  it 'changes status when no longer injured' do
    injured_player = FactoryBot.create(:player, injuries_count: 1)
    injured_player.injuries.last.update(description: Faker::Lorem.word, end_date: Time.now)
    expect(injured_player.active?).to be true
  end
  
  it 'changes status to loaned when loaned out' do
    player.loans.create(FactoryBot.attributes_for(:loan))
    expect(player.loaned?).to be true
  end
  
  it 'changes status when loan returns' do
    loaned_player = FactoryBot.create(:player, loans_count: 1)
    loaned_player.loans.last.update(end_date: Time.now)
    expect(loaned_player.active?).to be true
  end
  
  it 'changes status when player resigns (new contract)' do
    player.update(status: nil)
    player.contracts.create(FactoryBot.attributes_for(:contract))
    expect(player.active?).to be true
  end
  
  it 'is not eligible to play if injured' do
    injured_player = FactoryBot.create(:player, injuries_count: 1)
    expect(injured_player.active?).to be_falsey
  end

  it 'is not eligible to play if on loan' do
    loaned_player = FactoryBot.create(:player, loans_count: 1)
    expect(loaned_player.active?).to be_falsey
  end

  it 'is not eligible to play if out of the club' do
    player.update(status: nil)
    expect(player.active?).to be_falsey
  end


end
