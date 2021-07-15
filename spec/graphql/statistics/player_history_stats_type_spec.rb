# frozen_string_literal: true

require 'rails_helper'

describe Types::Statistics::PlayerHistoryStatsType do
  subject { described_class }

  it { is_expected.to have_field(:player_id).of_type('ID!') }
  it { is_expected.to have_field(:ovr).of_type('[Int!]!') }
  it { is_expected.to have_field(:value).of_type('[Int!]!') }
end
