# == Schema Information
#
# Table name: fixture_legs
#
#  id         :bigint(8)        not null, primary key
#  fixture_id :bigint(8)
#  home_score :string
#  away_score :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_fixture_legs_on_fixture_id  (fixture_id)
#

require 'rails_helper'

RSpec.describe FixtureLeg, type: :model do
  let(:fixture_leg) { FactoryBot.create(:fixture_leg) }

  it 'has a valid factory' do
    expect(fixture_leg).to be_valid
  end
end
