# frozen_string_literal: true

require 'rails_helper'

describe Types::Inputs::UserAttributes do
  subject { described_class }

  it { is_expected.to accept_argument(:email).of_type('String') }
  it { is_expected.to accept_argument(:username).of_type('String') }
  it { is_expected.to accept_argument(:full_name).of_type('String') }
  it { is_expected.to accept_argument(:dark_mode).of_type('Boolean') }
end
