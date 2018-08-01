# == Schema Information
#
# Table name: match_logs
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
#
# Indexes
#
#  index_match_logs_on_match_id   (match_id)
#  index_match_logs_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe MatchLog, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:match_log)).to be_valid
  end

  it 'requires a position' do
    expect(FactoryBot.build(:match_log, pos: nil)).to_not be_valid
  end

  it 'requires a player' do
    expect(FactoryBot.build(:match_log, player_id: nil)).to_not be_valid
  end

  it 'requires a start minute' do
    expect(FactoryBot.build(:match_log, start: nil)).to_not be_valid
  end

  it 'requires a stop minute' do
    expect(FactoryBot.build(:match_log, stop: nil)).to_not be_valid
  end

  it 'can not have a stop minute before the start minute' do
    expect(FactoryBot.build(:match_log, start: 46, stop: 45)).to_not be_valid
  end

end
