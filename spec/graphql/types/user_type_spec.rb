# frozen_string_literal: true

require 'rails_helper'

describe Types::UserType do
  subject { described_class }

  it { is_expected.to have_field(:id).of_type('ID!') }
  it { is_expected.to have_field(:email).of_type('String!') }
  it { is_expected.to have_field(:username).of_type('String!') }
  it { is_expected.to have_field(:full_name).of_type('String!') }
  it { is_expected.to have_field(:dark_mode).of_type('Boolean!') }
  it { is_expected.to have_field(:created_at).of_type('ISO8601DateTime!') }

  it { is_expected.to have_field(:teams).of_type('[Team!]!') }
end
