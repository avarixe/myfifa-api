# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id           :bigint           not null, primary key
#  active       :boolean          default(TRUE), not null
#  currency     :string           default("$")
#  currently_on :date
#  game         :string
#  manager_name :string
#  name         :string
#  started_on   :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  previous_id  :bigint
#  user_id      :bigint
#
# Indexes
#
#  index_teams_on_previous_id  (previous_id)
#  index_teams_on_user_id      (user_id)
#

require 'rails_helper'

describe Team do
  let(:team) { create(:team) }

  it 'has a valid factory' do
    expect(team).to be_valid
  end

  it 'requires a name' do
    expect(build(:team, name: nil)).not_to be_valid
  end

  it 'requires a manager name' do
    expect(build(:team, manager_name: nil)).not_to be_valid
  end

  it 'requires a start date' do
    expect(build(:team, started_on: nil)).not_to be_valid
  end

  it 'requires a currency' do
    expect(build(:team, currency: nil)).not_to be_valid
  end

  it 'caches the name as a Team Option' do
    expect(Option.where(category: 'Team', value: team.name)).to be_present
  end

  it '#badge_path returns the path for the attached badge' do
    team.badge.attach io: Rails.root.join('spec/support/test-badge.png').open,
                      filename: 'badge.png'
    expect(team.badge_path).to be_present
  end

  it '#opponents collects all teams from matches' do
    create_list(:match, 10, team:)
    expect(team.opponents)
      .to be == team.matches.reload.pluck(:home, :away).flatten.uniq.sort
  end

  it '#last_match returns the last Match bound to it' do
    create_list(:match, 2, team:)
    expect(team.last_match).to be == Match.order(:played_on).last
  end

  describe '#injured_players' do
    let(:player) { create(:player, team:) }

    it 'includes injured Players bound to it' do
      create(:injury, player:, started_on: team.currently_on)
      expect(team.injured_players).to include(player)
    end

    it 'does not include non-injured Players bound to it' do
      expect(team.injured_players).not_to include(player)
    end
  end

  describe '#loaned_players' do
    let(:player) { create(:player, team:) }

    it 'includes Players loaned from it' do
      create(:loan,
             player:,
             origin: team.name,
             signed_on: team.currently_on,
             started_on: team.currently_on)
      expect(team.loaned_players).to include(player)
    end

    it 'does not include non-loaned Players bound to it' do
      expect(team.loaned_players).not_to include(player)
    end

    it 'does not include Played loaned to it' do
      create(:loan,
             player:,
             destination: team.name,
             started_on: team.currently_on)
      expect(team.loaned_players).not_to include(player)
    end
  end

  describe '#expiring_players' do
    let(:player) { create(:player, team:, contracts_count: 0) }

    it 'includes Players with contracts ending after the current season' do
      create(:contract,
             player:,
             ended_on: team.end_of_current_season + 1.day)
      expect(team.expiring_players).to include(player)
    end

    it 'does not include Players with contracts that already ended' do
      create(:contract,
             player:,
             signed_on: team.currently_on,
             ended_on: team.currently_on + 1.month)
      team.increment_date 1.year
      expect(team.expiring_players).not_to include(player)
    end

    it 'does not include Played with expiring contrcts that were renewed' do
      create(:contract,
             player:,
             signed_on: team.currently_on,
             ended_on: team.currently_on + 1.month)
      create(:contract,
             player:,
             signed_on: team.currently_on,
             ended_on: team.currently_on + 2.years)
      expect(team.expiring_players).not_to include(player)
    end
  end

  it '#injured_players returns all injured Players bound to it' do
    players = create_list(:player, 3, team:)
    players.each do |player|
      create(:injury, player:, started_on: team.currently_on)
      expect(team.injured_players).to include(player)
    end
  end

  describe 'when currently_on changes' do
    it 'updates Player status to Pending when applicable' do
      player = create(:player, team:, contracts_count: 0)
      create(:contract,
             player:,
             signed_on: team.currently_on + 1.week,
             started_on: team.currently_on + 1.month)
      team.increment_date 1.week
      expect(player.reload.status).to be == 'Pending'
    end

    it 'does not change Player status if contract is unsigned' do
      player = create(:player, team:, contracts_count: 0)
      create(:contract,
             player:,
             started_on: team.currently_on + 1.month)
      team.increment_date 1.week
      expect(player.reload.status).not_to be == 'Pending'
    end

    it 'updates Player status to Active when applicable' do
      player = create(:player, team:, contracts_count: 0)
      create(:contract,
             player:,
             signed_on: team.currently_on,
             started_on: team.currently_on + 1.week)
      team.increment_date 1.week
      expect(player.reload.status).to be == 'Active'
    end

    it 'does not update Player status to Active if contract is unsigned' do
      player = create(:player, team:, contracts_count: 0)
      create(:contract,
             player:,
             started_on: team.currently_on + 1.week)
      team.increment_date 1.week
      expect(player.reload.status).not_to be == 'Active'
    end

    it 'updates Player status to Injured when applicable' do
      player = create(:player, team:)
      create(:injury, player:, started_on: team.currently_on + 1.week)
      team.increment_date 1.week
      expect(player.reload.status).to be == 'Injured'
    end

    it 'updates Player status to Loaned when applicable' do
      player = create(:player, team:)
      create(:loan,
             player:,
             signed_on: team.currently_on,
             started_on: team.currently_on + 1.week)
      team.increment_date 1.week
      expect(player.reload.status).to be == 'Loaned'
    end

    it 'does not update Player status to Loaned if unsigned' do
      player = create(:player, team:)
      create(:loan, player:, started_on: team.currently_on + 1.week)
      team.increment_date 1.week
      expect(player.reload.status).not_to be == 'Loaned'
    end

    it 'updates Player status if signed Transfer occurs' do
      player = create(:player, team:)
      create(:transfer,
             player:,
             origin: team.name,
             signed_on: team.currently_on,
             moved_on: team.currently_on + 1.week)
      team.increment_date 1.week
      expect(player.reload.status).to be_blank
    end

    it 'does not update Player status if Transfer is unsigned' do
      player = create(:player, team:)
      create(:transfer,
             player:,
             origin: team.name,
             moved_on: team.currently_on + 1.week)
      team.increment_date 1.week
      expect(player.reload.status).to be == 'Active'
    end
  end
end
