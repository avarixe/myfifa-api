# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id           :bigint           not null, primary key
#  active       :boolean          default(TRUE), not null
#  currency     :string           default("$")
#  currently_on :date
#  name         :string
#  started_on   :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint
#
# Indexes
#
#  index_teams_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe Team, type: :model do
  let(:team) { create(:team) }

  it "has a valid factory" do
    expect(team).to be_valid
  end

  it 'requires a name' do
    expect(build(:team, name: nil)).to_not be_valid
  end

  it 'requires a start date' do
    expect(build(:team, started_on: nil)).to_not be_valid
  end

  it 'requires a currency' do
    expect(build(:team, currency: nil)).to_not be_valid
  end
end
