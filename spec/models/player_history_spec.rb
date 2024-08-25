# frozen_string_literal: true

# == Schema Information
#
# Table name: player_histories
#
#  id          :bigint           not null, primary key
#  kit_no      :integer
#  ovr         :integer
#  recorded_on :date
#  value       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  player_id   :bigint
#
# Indexes
#
#  index_player_histories_on_player_id  (player_id)
#

require 'rails_helper'

describe PlayerHistory do
  it 'has a valid factory' do
    expect(create(:player_history)).to be_valid
  end

  it 'requires a datestamp' do
    expect(build(:player_history, recorded_on: nil)).not_to be_valid
  end

  it 'requires an overall rating' do
    expect(build(:player_history, ovr: nil)).not_to be_valid
  end

  it 'requires a value' do
    expect(build(:player_history, value: nil)).not_to be_valid
  end

  it 'updates Player Cap OVR when created' do
    player = create(:player, ovr: 70)
    cap = create(:cap, player:)
    player.update(ovr: 71)
    expect(cap.reload.ovr).to eq 71
  end

  it 'updates Player Cap OVR when updated' do
    player = create(:player, ovr: 70)
    cap = create(:cap, player:)
    player.histories.last.update ovr: 71
    expect(cap.reload.ovr).to eq 71
  end
end
