# frozen_string_literal: true

require 'rails_helper'

describe InputObjects::PaginationAttributes do
  subject { described_class }

  it { is_expected.to accept_argument(:page).of_type('Int!') }
  it { is_expected.to accept_argument(:items_per_page).of_type('Int!') }
  it { is_expected.to accept_argument(:sort_by).of_type('String') }
  it { is_expected.to accept_argument(:sort_desc).of_type('Boolean') }
end
