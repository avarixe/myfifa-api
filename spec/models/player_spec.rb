# frozen_string_literal: true

# == Schema Information
#
# Table name: players
#
#  id          :bigint           not null, primary key
#  birth_year  :integer
#  coverage    :jsonb            not null
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
#  index_players_on_coverage  (coverage) USING gin
#  index_players_on_team_id   (team_id)
#

require 'rails_helper'

describe Player do
  let(:player) { create(:player) }

  it 'has a valid factory' do
    expect(player).to be_valid
  end

  it 'requires a name' do
    expect(build(:player, name: nil)).not_to be_valid
  end

  it 'requires a position' do
    expect(build(:player, pos: nil)).not_to be_valid
  end

  it 'requires an OVR' do
    expect(build(:player, ovr: nil)).not_to be_valid
  end

  it 'requires a value' do
    expect(build(:player, value: nil)).not_to be_valid
  end

  it 'requires a birth year' do
    expect(build(:player, birth_year: nil)).not_to be_valid
  end

  it 'requires all secondary positions to be valid' do
    expect(build(:player, sec_pos: [''])).not_to be_valid
  end

  it 'requires all coverage keys to be valid' do
    expect(build(:player, coverage: { 'NA' => 1 })).not_to be_valid
  end

  it 'requires all coverage values to be valid' do
    expect(build(:player, coverage: { 'CM' => 3 })).not_to be_valid
  end

  it 'filters out null values from coverage' do
    player = create(:player, coverage: { 'CM' => 1, 'RCM' => nil })
    expect(player.coverage).not_to have_key('RCM')
  end

  it 'sets default coverage with pos/sec_pos if blank' do
    player = create(:player, pos: 'CM', sec_pos: %w[LM RM])
    expect(player.coverage).to be == { 'CM' => 1, 'LM' => 2, 'RM' => 2 }
  end

  it 'starts with a history record' do
    expect(player.histories.length).to be == 1
  end

  it 'sets birth_year automatically if age is provided' do
    player.birth_year = nil
    player.age = player.team.currently_on.year - player.birth_year_was
    expect(player.birth_year).to be == player.birth_year_was
  end

  it 'sets age based on team date and birth year' do
    expected_age = Faker::Number.within(range: 18..30)
    player.birth_year = player.team.currently_on.year - expected_age
    expect(player.age).to be == expected_age
  end

  describe 'when ovr is changed' do
    before do
      player.team.increment_date(1.day)
      player.update(ovr: player.ovr + 1)
      player.histories.reload
    end

    it 'creates new history record' do
      expect(player.histories.length).to be == 2
    end

    it 'stores new ovr in history' do
      expect(player.histories.last.ovr).to be == player.ovr
    end
  end

  describe 'when ovr/value is changed on same date' do
    before do
      player.team.increment_date(1.day)
      player.update(ovr: player.ovr + 1)
      player.update(value: player.value + 1_000_000)
      player.histories.reload
    end

    it 'does not create an extra history record' do
      expect(player.histories.length).to be == 2
    end

    it 'stores new value in history' do
      expect(player.histories.last.value).to be == player.value
    end
  end
end
