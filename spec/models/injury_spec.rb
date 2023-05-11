# frozen_string_literal: true

# == Schema Information
#
# Table name: injuries
#
#  id          :bigint           not null, primary key
#  description :string
#  ended_on    :date
#  started_on  :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  player_id   :bigint
#
# Indexes
#
#  index_injuries_on_player_id  (player_id)
#

require 'rails_helper'

describe Injury do
  let(:injury) do
    player = create(:player)
    create(:injury,
           started_on: player.team.currently_on,
           player:)
  end

  it 'has a valid factory' do
    expect(create(:injury)).to be_valid
  end

  it 'requires a description' do
    expect(build(:injury, description: nil)).not_to be_valid
  end

  it 'has an end date after start date' do
    injury = build(:injury,
                   started_on: Faker::Date.forward(days: 1),
                   ended_on: Faker::Date.backward(days: 1))
    expect(injury).not_to be_valid
  end

  it 'is rejected for already injured Players' do
    injury2 = build(:injury,
                    started_on: injury.team.currently_on,
                    player: injury.player)
    expect(injury2).not_to be_valid
  end

  it 'changes Player status to injured when injured' do
    expect(injury.player.injured?).to be true
  end

  it 'changes Player status when no longer injured' do
    player = injury.player
    player.team.increment_date 1.week
    player.injuries.last.update(ended_on: player.team.currently_on)
    expect(player.active?).to be true
  end

  %w[Days Weeks Months Years].each do |timespan|
    it "automatically sets ended_on when #{timespan} duration is provided" do
      injury.duration = { length: 3, timespan: }
      expect(injury.ended_on)
        .to be == injury.team.currently_on + 3.public_send(timespan.downcase)
    end
  end
end
