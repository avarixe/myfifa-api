# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Inputs::CapAttributes do
  subject { described_class }

  it { is_expected.to accept_argument(:player_id).of_type('Int!') }
  it { is_expected.to accept_argument(:pos).of_type('String!') }
end
