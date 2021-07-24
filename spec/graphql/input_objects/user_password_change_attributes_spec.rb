# frozen_string_literal: true

require 'rails_helper'

describe InputObjects::UserPasswordChangeAttributes do
  subject { described_class }

  it { is_expected.to accept_argument(:password).of_type('String!') }
  it { is_expected.to accept_argument(:password_confirmation).of_type('String!') }
  it { is_expected.to accept_argument(:current_password).of_type('String!') }
end
