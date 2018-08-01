# == Schema Information
#
# Table name: squads
#
#  id             :bigint(8)        not null, primary key
#  team_id        :bigint(8)
#  name           :string
#  players_list   :text             default([]), is an Array
#  positions_list :text             default([]), is an Array
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_squads_on_team_id  (team_id)
#

require 'rails_helper'

RSpec.describe Squad, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:squad)).to be_valid
  end
end
