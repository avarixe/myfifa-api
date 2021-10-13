# frozen_string_literal: true

require 'rails_helper'

describe Types::Statistics::TeamDevelopmentStatsType do
  subject { described_class }

  it { is_expected.to have_field(:season).of_type('Int!') }
  it { is_expected.to have_field(:start_ovr).of_type('Int!') }
  it { is_expected.to have_field(:start_value).of_type('Int!') }
  it { is_expected.to have_field(:end_ovr).of_type('Int!') }
  it { is_expected.to have_field(:end_value).of_type('Int!') }
end
