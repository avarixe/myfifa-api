# frozen_string_literal: true

require 'rails_helper'

describe InputObjects::LoanAttributes do
  subject { described_class }

  it { is_expected.to accept_argument(:started_on).of_type('ISO8601Date!') }
  it { is_expected.to accept_argument(:ended_on).of_type('ISO8601Date') }
  it { is_expected.to accept_argument(:destination).of_type('String!') }
  it { is_expected.to accept_argument(:origin).of_type('String!') }
  it { is_expected.to accept_argument(:wage_percentage).of_type('Int') }
  it { is_expected.to accept_argument(:transfer_fee).of_type('Int') }
  it { is_expected.to accept_argument(:addon_clause).of_type('Int') }

  it { is_expected.to accept_argument(:returned).of_type('Boolean') }
  it { is_expected.to accept_argument(:activated_buy_option).of_type('Boolean') }
end
