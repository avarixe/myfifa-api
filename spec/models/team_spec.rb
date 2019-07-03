# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id           :bigint(8)        not null, primary key
#  user_id      :bigint(8)
#  title        :string
#  started_on   :date
#  currently_on :date
#  active       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  currency     :string           default("$")
#
# Indexes
#
#  index_teams_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe Team, type: :model do
  let(:team) { FactoryBot.create(:team) }

  it "has a valid factory" do
    expect(team).to be_valid
  end

  it 'requires a title' do
    expect(FactoryBot.build(:team, title: nil)).to_not be_valid
  end

  it 'requires a start date' do
    expect(FactoryBot.build(:team, started_on: nil)).to_not be_valid
  end

  it 'requires a currency' do
    expect(FactoryBot.build(:team, currency: nil)).to_not be_valid
  end
end
