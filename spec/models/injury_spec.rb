# == Schema Information
#
# Table name: injuries
#
#  id          :bigint(8)        not null, primary key
#  player_id   :bigint(8)
#  start_date  :date
#  end_date    :date
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_injuries_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Injury, type: :model do
  let(:player) { FactoryBot.create(:player)}

  it "has a valid factory" do
    expect(FactoryBot.create(:injury)).to be_valid
  end

  it 'requires a description' do
    expect(FactoryBot.build(:injury, description: nil)).to_not be_valid
  end

  it 'has an end date after start date' do
    expect(FactoryBot.build(:injury, start_date: Faker::Date.forward(1), end_date: Faker::Date.backward(1))).to_not be_valid
  end

  it 'occurs on the Team current date' do
    injury = FactoryBot.create(:injury)
    expect(injury.start_date).to be == injury.team.current_date
    injury.team.increment_date(2.days)
    injury.update(recovered: true)
    expect(injury.end_date).to be == injury.team.current_date
  end

  it 'changes Player status to injured when injured' do
    player.injuries.create(FactoryBot.attributes_for(:injury))
    expect(player.injured?).to be true
  end
  
  it 'changes Player status when no longer injured' do
    player.injuries.create(FactoryBot.attributes_for(:injury))
    player.injuries.last.update(recovered: true)
    expect(player.active?).to be true
  end
end
