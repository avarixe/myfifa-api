# == Schema Information
#
# Table name: injuries
#
#  id          :integer          not null, primary key
#  player_id   :integer
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
  let(:end_date) { Faker::Date.forward(30) }

  it "has a valid factory" do
    expect(FactoryBot.create(:injury)).to be_valid
  end

  it 'requires a start date' do
    expect(FactoryBot.build(:injury, start_date: nil)).to_not be_valid
  end

  it 'has an end date after start date' do
    expect(FactoryBot.build(:injury, start_date: Faker::Date.forward(1), end_date: Faker::Date.backward(1))).to_not be_valid
  end

end
