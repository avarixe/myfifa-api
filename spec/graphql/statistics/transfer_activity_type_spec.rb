# frozen_string_literal: true

require 'rails_helper'

describe Types::Statistics::TransferActivityType do
  subject { described_class }

  it { is_expected.to have_field(:arrivals).of_type('[Contract!]!') }
  it { is_expected.to have_field(:departures).of_type('[Contract!]!') }
  it { is_expected.to have_field(:transfers).of_type('[Transfer!]!') }
  it { is_expected.to have_field(:loans).of_type('[Loan!]!') }
end
