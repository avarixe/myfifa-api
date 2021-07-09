# frozen_string_literal: true

# == Schema Information
#
# Table name: players
#
#  id          :bigint           not null, primary key
#  birth_year  :integer
#  kit_no      :integer
#  name        :string
#  nationality :string
#  ovr         :integer
#  pos         :string
#  sec_pos     :text             default([]), is an Array
#  status      :string
#  value       :integer
#  youth       :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team_id     :bigint
#
# Indexes
#
#  index_players_on_team_id  (team_id)
#

require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:player) { create(:player) }

  it "has a valid factory" do
    expect(player).to be_valid
  end

  it 'requires a name' do
    expect(build(:player, name: nil)).to_not be_valid
  end

  it 'requires a valid position' do
    expect(build(:player, pos: nil)).to_not be_valid
    expect(build(:player, pos: 'GKK')).to_not be_valid
  end

  it 'requires an valid OVR' do
    expect(build(:player, ovr: nil)).to_not be_valid
    expect(build(:player, ovr: -1)).to_not be_valid
  end

  it 'requires a valid value' do
    expect(build(:player, value: nil)).to_not be_valid
    expect(build(:player, value: -1)).to_not be_valid
  end

  it 'requires a birth year' do
    expect(build(:player, birth_year: nil)).to_not be_valid
    expect(build(:player, value: -1)).to_not be_valid
  end

  it 'requires all secondary positions to be valid' do
    sec_pos = []
    3.times do
      sec_pos << Player::POSITIONS.sample
    end
    expect(build(:player, sec_pos: [''])).to_not be_valid
    expect(build(:player, sec_pos: sec_pos)).to be_valid
  end

  it 'starts with a history record' do
    expect(player.histories.length).to be == 1
  end

  it 'sets birth_year automatically if age is provided' do
    player.birth_year = nil
    player.age = player.team.currently_on.year - player.birth_year_was
    expect(player.birth_year_changed?).to be_falsey
  end

  it 'records attribute changes in history' do
    player.team.increment_date(1.day)

    player.ovr += 1
    player.save!
    player.histories.reload
    expect(player.histories.length).to be == 2
    expect(player.histories.last.ovr).to be == player.ovr

    player.value += 1_000_000
    player.save!
    player.histories.reload
    expect(player.histories.length).to be == 2
    expect(player.histories.last.value).to be == player.value
  end
end
