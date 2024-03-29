# frozen_string_literal: true

# == Schema Information
#
# Table name: fixtures
#
#  id         :bigint           not null, primary key
#  away_team  :string
#  home_team  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  stage_id   :bigint
#
# Indexes
#
#  index_fixtures_on_stage_id  (stage_id)
#

require 'rails_helper'

describe Fixture do
  let(:fixture) { create(:fixture) }

  it 'has a valid factory' do
    expect(fixture).to be_valid
  end

  it 'requires at least one FixtureLeg' do
    expect(build(:fixture, legs_count: 0)).not_to be_valid
  end

  it 'caches the Home Team as a Team Option' do
    expect(Option.where(category: 'Team', value: fixture.home_team)).to be_present
  end

  it 'caches the Away Team as a Team Option' do
    expect(Option.where(category: 'Team', value: fixture.away_team)).to be_present
  end
end
