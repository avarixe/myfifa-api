# == Schema Information
#
# Table name: loans
#
#  id          :bigint(8)        not null, primary key
#  player_id   :bigint(8)
#  start_date  :date
#  end_date    :date
#  destination :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_loans_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Loan, type: :model do

   it "has a valid factory" do
    expect(FactoryBot.create(:loan)).to be_valid
  end
  
  it 'requires a start date' do
    expect(FactoryBot.build(:loan, start_date: nil)).to_not be_valid
  end

  it 'requires a destination' do
    expect(FactoryBot.build(:loan, destination: nil)).to_not be_valid
  end
  
  it 'has an end date after start date' do
    expect(FactoryBot.build(:loan, start_date: Faker::Date.forward(1), destination: Faker::Lorem.word, end_date: Faker::Date.backward(1))).to_not be_valid
  end
end
