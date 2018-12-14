# == Schema Information
#
# Table name: fixtures
#
#  id         :bigint(8)        not null, primary key
#  stage_id   :bigint(8)
#  home_team  :string
#  away_team  :string
#  home_score :string
#  away_score :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_fixtures_on_stage_id  (stage_id)
#

require 'rails_helper'

RSpec.describe Fixture, type: :model do
  let(:fixture) { FactoryBot.create(:fixture) }

  it 'has a valid factory' do
    expect(fixture).to be_valid
  end
end
