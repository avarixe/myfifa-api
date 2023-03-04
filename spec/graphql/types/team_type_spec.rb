# frozen_string_literal: true

require 'rails_helper'

describe Types::TeamType do
  subject { described_class }

  it { is_expected.to have_field(:id).of_type('ID!') }

  it { is_expected.to have_field(:user_id).of_type('ID!') }
  it { is_expected.to have_field(:name).of_type('String!') }
  it { is_expected.to have_field(:started_on).of_type('ISO8601Date!') }
  it { is_expected.to have_field(:currently_on).of_type('ISO8601Date!') }
  it { is_expected.to have_field(:active).of_type('Boolean!') }
  it { is_expected.to have_field(:created_at).of_type('ISO8601DateTime!') }
  it { is_expected.to have_field(:currency).of_type('String!') }

  it { is_expected.to have_field(:badge_path).of_type('String') }
  it { is_expected.to have_field(:opponents).of_type('[String!]!') }
  it { is_expected.to have_field(:last_match).of_type('Match') }

  it { is_expected.to have_field(:players).of_type('[Player!]!') }
  it { is_expected.to have_field(:matches).of_type('[Match!]!') }
  it { is_expected.to have_field(:competitions).of_type('[Competition!]!') }
  it { is_expected.to have_field(:squads).of_type('[Squad!]!') }

  it { is_expected.to have_field(:loaned_players).of_type('[Player!]!') }
  it { is_expected.to have_field(:injured_players).of_type('[Player!]!') }
  it { is_expected.to have_field(:expiring_players).of_type('[Player!]!') }

  describe 'matchSet field' do
    subject(:field) { described_class.fields['matchSet'] }

    it { is_expected.to be_of_type('MatchSet!') }
    it { is_expected.to accept_argument(:pagination).of_type('PaginationAttributes') }
    it { is_expected.to accept_argument(:filters).of_type('MatchFilterAttributes') }
  end

  describe 'competitionStats field' do
    subject(:field) { described_class.fields['competitionStats'] }

    it { is_expected.to be_of_type('[CompetitionStats!]!') }
    it { is_expected.to accept_argument(:competition).of_type('String') }
    it { is_expected.to accept_argument(:season).of_type('Int') }
  end

  describe 'playerPerformanceStats field' do
    subject(:field) { described_class.fields['playerPerformanceStats'] }

    it { is_expected.to be_of_type('[PlayerPerformanceStats!]!') }
    it { is_expected.to accept_argument(:player_ids).of_type('[ID!]') }
    it { is_expected.to accept_argument(:competition).of_type('String') }
    it { is_expected.to accept_argument(:season).of_type('Int') }
  end

  describe 'playerDevelopmentStats field' do
    subject(:field) { described_class.fields['playerDevelopmentStats'] }

    it { is_expected.to be_of_type('[PlayerDevelopmentStats!]!') }
    it { is_expected.to accept_argument(:player_ids).of_type('[ID!]') }
    it { is_expected.to accept_argument(:season).of_type('Int') }
  end

  describe 'transferActivity field' do
    subject(:field) { described_class.fields['transferActivity'] }

    it { is_expected.to be_of_type('TransferActivity!') }
    it { is_expected.to accept_argument(:season).of_type('Int') }
  end

  describe 'teamDevelopmentStats field' do
    subject(:field) { described_class.fields['teamDevelopmentStats'] }

    it { is_expected.to be_of_type('TeamDevelopmentStats!') }
    it { is_expected.to accept_argument(:season).of_type('Int!') }
  end
end
