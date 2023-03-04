# frozen_string_literal: true

require 'rails_helper'

describe InputObjects::MatchFilterAttributes do
  subject { described_class }

  it { is_expected.to accept_argument(:season).of_type('Int') }
  it { is_expected.to accept_argument(:competition).of_type('String') }
  it { is_expected.to accept_argument(:stage).of_type('String') }
  it { is_expected.to accept_argument(:team).of_type('String') }
  it { is_expected.to accept_argument(:result).of_type('[MatchResult!]') }
  it { is_expected.to accept_argument(:start_on).of_type('ISO8601Date') }
  it { is_expected.to accept_argument(:end_on).of_type('ISO8601Date') }
end
