# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ApplySquadToMatch do
  subject { described_class }

  it { is_expected.to accept_argument(:match_id).of_type('ID!') }
  it { is_expected.to accept_argument(:squad_id).of_type('ID!') }
  it { is_expected.to have_a_field(:match).returning('Match!') }
end
