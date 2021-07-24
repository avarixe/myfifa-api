# frozen_string_literal: true

require 'rails_helper'

describe InputObjects::UserRegistrationAttributes do
  subject { described_class }

  it { is_expected.to accept_argument(:email).of_type('String!') }
  it { is_expected.to accept_argument(:username).of_type('String!') }
  it { is_expected.to accept_argument(:full_name).of_type('String!') }
  it { is_expected.to accept_argument(:password).of_type('String!') }
  it { is_expected.to accept_argument(:password_confirmation).of_type('String!') }
end
