# == Schema Information
#
# Table name: teams
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  title        :string
#  start_date   :date
#  current_date :date
#  active       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_teams_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe Team, type: :model do
  let(:team) { FactoryBot.create(:team) }

  it "has a valid factory" do
    expect(team).to be_valid
  end
  
  it 'requires a title' do
    expect(FactoryBot.build(:team, title: nil)).to_not be_valid
  end

  it 'requires a start date' do
    expect(FactoryBot.build(:team, start_date: nil)).to_not be_valid
  end
  
  it 'checks for expired player contracts' do
    player = team.players.create(FactoryBot.attributes_for(:player))
    player.contracts.create(FactoryBot.attributes_for(:contract))
    team.update(current_date: player.contracts.last.end_date + 1.day)
    expect(team.players.last.status).to be_nil
  end

end
