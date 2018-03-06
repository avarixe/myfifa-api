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
  it "has a valid factory" do
    expect(FactoryBot.create(:team)).to be_valid
  end
end
