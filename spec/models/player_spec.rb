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
#
# Indexes
#
#  index_players_on_team_id  (team_id)
#

require 'rails_helper'

RSpec.describe Player, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:player)).to be_valid
  end
  it 'has an initial contract'
  it 'records history of age, ovr, value when any changes'

end
