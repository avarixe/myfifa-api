# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id           :bigint           not null, primary key
#  active       :boolean          default(TRUE), not null
#  currency     :string           default("$")
#  currently_on :date
#  name         :string
#  started_on   :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint
#
# Indexes
#
#  index_teams_on_user_id  (user_id)
#

require 'rails_helper'

describe Team, type: :model do
  let(:team) { create :team }

  it 'has a valid factory' do
    expect(team).to be_valid
  end

  it 'requires a name' do
    expect(build(:team, name: nil)).not_to be_valid
  end

  it 'requires a start date' do
    expect(build(:team, started_on: nil)).not_to be_valid
  end

  it 'requires a currency' do
    expect(build(:team, currency: nil)).not_to be_valid
  end

  it '#badge_path returns the path for the attached badge' do
    team.badge.attach io: File.open(Rails.root.join('spec/support/test-badge.png')),
                      filename: 'badge.png'
    expect(team.badge_path).to be_present
  end

  it '#opponents collects all teams from matches' do
    create_list :match, 10, team: team
    expect(team.opponents)
      .to be == team.matches.reload.pluck(:home, :away).flatten.uniq.sort
  end

  it '#last_match returns the last Match bound to it' do
    create_list :match, 2, team: team
    expect(team.last_match).to be == Match.order(:played_on).last
  end

  describe 'when currently_on changes' do
    it 'updates Player status to Pending when applicable' do
      player = create :player, team: team, contracts_count: 0
      create :contract,
             player: player,
             signed_on: team.currently_on + 1.week,
             started_on: team.currently_on + 1.month
      team.increment_date 1.week
      expect(player.reload.status).to be == 'Pending'
    end

    it 'updates Player status to Active when applicable' do
      player = create :player, team: team, contracts_count: 0
      create :contract,
             player: player,
             started_on: team.currently_on + 1.week
      team.increment_date 1.week
      expect(player.reload.status).to be == 'Active'
    end

    it 'updates Player status to Injured when applicable' do
      player = create :player, team: team
      create :injury, player: player, started_on: team.currently_on + 1.week
      team.increment_date 1.week
      expect(player.reload.status).to be == 'Injured'
    end

    it 'updates Player status to Loaned when applicable' do
      player = create :player, team: team
      create :loan, player: player, started_on: team.currently_on + 1.week
      team.increment_date 1.week
      expect(player.reload.status).to be == 'Loaned'
    end
  end
end
