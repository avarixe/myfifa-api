# frozen_string_literal: true

# == Schema Information
#
# Table name: substitutions
#
#  id             :bigint           not null, primary key
#  injury         :boolean          default(FALSE), not null
#  minute         :integer
#  player_name    :string
#  replaced_by    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  cap_id         :bigint
#  match_id       :bigint
#  player_id      :bigint
#  replacement_id :bigint
#  sub_cap_id     :bigint
#
# Indexes
#
#  index_substitutions_on_cap_id          (cap_id)
#  index_substitutions_on_match_id        (match_id)
#  index_substitutions_on_player_id       (player_id)
#  index_substitutions_on_replacement_id  (replacement_id)
#  index_substitutions_on_sub_cap_id      (sub_cap_id)
#

require 'rails_helper'

describe Substitution do
  let(:match) { create(:match) }
  let(:subbed_cap) do
    player = create(:player, team: match.team)
    create(:cap, start: 0, stop: 90, match:, player:)
  end
  let(:sub) do
    replacement = create(:player, team: match.team)
    create(:substitution, subbed_cap:, replacement:, match:)
  end

  it 'has a valid factory' do
    expect(create(:substitution)).to be_valid
  end

  it 'requires a cap' do
    expect(build(:substitution, subbed_cap: nil)).not_to be_valid
  end

  it 'requires a match' do
    expect(build(:substitution, match: nil)).not_to be_valid
  end

  it 'requires a minute' do
    expect(build(:substitution, minute: nil)).not_to be_valid
  end

  it 'requires a replacement' do
    expect(build(:substitution, replacement: nil)).not_to be_valid
  end

  it 'automatically sets player name' do
    expect(sub.player_name).to be == sub.player.name
  end

  it 'automatically sets replaced by' do
    expect(sub.replaced_by).to be == sub.replacement.name
  end

  it 'creates a Cap record upon creation' do
    expect(sub.sub_cap).to be_present
  end

  it 'marks replaced Cap record as subbed_out' do
    expect(sub.subbed_cap).to be_subbed_out
  end

  describe 'in extra time' do
    let(:match) { create(:match, extra_time: true) }
    let(:sub) do
      replacement = create(:player, team: match.team)
      create(:substitution,
             player_id: subbed_cap.player_id,
             replacement_id: replacement.id,
             match:,
             minute: Faker::Number.between(from: 91, to: 120))
    end

    it 'creates a Cap record upon creation' do
      expect(sub.sub_cap).to be_present
    end
  end

  describe 'when destroyed' do
    before do
      sub.destroy
    end

    it 'removes the Cap record' do
      expect(match.caps.count).to be == 1
    end

    it 'marks replaced Cap record as not subbed_out' do
      expect(subbed_cap).not_to be_subbed_out
    end
  end

  describe 'upon cap_id change' do
    let(:player2) { create(:player, team: match.team) }

    before do
      pos2 = Cap::POSITIONS[Cap::POSITIONS.index(subbed_cap.pos) - 1]
      cap2 = create(:cap, start: 0, stop: 90, match:, player: player2, pos: pos2)
      sub.update!(cap_id: cap2.id)
    end

    it 'automatically changes player id' do
      expect(sub.player_id).to be == player2.id
    end

    it 'automatically changes player name' do
      expect(sub.player_name).to be == player2.name
    end

    it 'marks replaced Cap as not subbed_out' do
      expect(subbed_cap.reload).not_to be_subbed_out
    end

    it 'marks new Player Cap as subbed_out' do
      cap = match.caps.find_by(player_id: player2.id)
      expect(cap).to be_subbed_out
    end
  end

  describe 'upon replacement_id change' do
    let(:player2) { create(:player, team: match.team) }

    before do
      sub.update(replacement_id: player2.id)
    end

    it 'automatically changes replaced by' do
      expect(sub.replaced_by).to be == player2.name
    end

    it 'detaches from old Player Cap' do
      caps = match.caps.where.not(player_id: [sub.player_id, sub.replacement_id])
      expect(caps).not_to be_present
    end

    it 'attaches to new Player Cap' do
      cap = match.caps.find_by(player_id: player2.id)
      expect(cap).not_to be_nil
    end
  end
end
