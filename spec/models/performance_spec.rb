# == Schema Information
#
# Table name: performances
#
#  id         :bigint(8)        not null, primary key
#  match_id   :bigint(8)
#  player_id  :bigint(8)
#  pos        :string
#  start      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  stop       :integer
#  subbed_out :boolean          default(FALSE)
#  rating     :integer
#
# Indexes
#
#  index_performances_on_match_id   (match_id)
#  index_performances_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Performance, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:performance)).to be_valid
  end

  it 'requires a position' do
    expect(FactoryBot.build(:performance, pos: nil)).to_not be_valid
  end

  it 'requires a player' do
    expect(FactoryBot.build(:performance, player_id: nil)).to_not be_valid
  end

  it 'requires a start minute' do
    expect(FactoryBot.build(:performance, start: nil)).to_not be_valid
  end

  it 'requires a stop minute' do
    expect(FactoryBot.build(:performance, stop: nil)).to_not be_valid
  end

  it 'requires a valid rating' do
    expect(FactoryBot.build(:performance, rating: nil)).to_not be_valid
    expect(FactoryBot.build(:performance, rating: 0)).to_not be_valid
    expect(FactoryBot.build(:performance, rating: 6)).to_not be_valid
  end

  it 'can not have a stop minute before the start minute' do
    expect(FactoryBot.build(:performance, start: 46, stop: 45)).to_not be_valid
  end

end
