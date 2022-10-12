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

class Fixture < ApplicationRecord
  include Broadcastable

  belongs_to :stage
  has_many :legs,
           -> { order :id },
           class_name: 'FixtureLeg',
           inverse_of: :fixture,
           dependent: :destroy

  accepts_nested_attributes_for :legs, allow_destroy: true

  cache_options 'Team', :home_team, :away_team

  validates :legs, length: { minimum: 1 }, on: :create

  delegate :team, to: :stage
end
