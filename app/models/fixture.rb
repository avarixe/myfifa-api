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
           class_name: 'FixtureLeg',
           inverse_of: :fixture,
           dependent: :destroy

  accepts_nested_attributes_for :legs, allow_destroy: true

  PERMITTED_ATTRIBUTES = %i[
    home_team
    away_team
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :legs,
            length: { minimum: 1, message: 'are missing for Fixture' }

  delegate :team, :competition_id, to: :stage

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] += %i[competition_id legs]
    super
  end
end
