# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AddTeam do
  subject { described_class }

  it { is_expected.to accept_argument(:attributes).of_type('TeamAttributes!') }
  it { is_expected.to have_a_field(:team).returning('Team') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }
end
