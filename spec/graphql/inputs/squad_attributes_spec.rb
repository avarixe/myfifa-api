# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Inputs::SquadAttributes do
  subject { described_class }

  it { is_expected.to accept_argument(:name).of_type('String!') }
  it { is_expected.to accept_argument(:squad_players_attributes).of_type('[SquadPlayerAttributes!]!') }
end
