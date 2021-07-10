# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ReleasePlayer do
  subject { described_class }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:player).returning('Player!') }
end
