# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::RemoveMutations do
  %w[
    Booking
    Cap
    Competition
    Contract
    Fixture
    Goal
    Injury
    Loan
    Match
    Player
    Squad
    Stage
    Substitution
    TableRow
    Team
    Transfer
  ].each do |model|
    describe described_class.const_get("Remove#{model}") do
      subject { described_class }

      it { is_expected.to accept_argument(:id).of_type('ID!') }
      it { is_expected.to have_a_field(model.underscore.to_sym).returning(model) }
      it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }
    end
  end
end
