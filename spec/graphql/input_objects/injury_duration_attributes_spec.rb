# frozen_string_literal: true

require 'rails_helper'

describe InputObjects::InjuryDurationAttributes do
  subject { described_class }

  it { is_expected.to accept_argument(:length).of_type('Int!') }
  it { is_expected.to accept_argument(:timespan).of_type('String!') }
end
