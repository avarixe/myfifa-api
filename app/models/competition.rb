# frozen_string_literal: true

# == Schema Information
#
# Table name: competitions
#
#  id         :bigint(8)        not null, primary key
#  team_id    :bigint(8)
#  season     :integer
#  name       :string
#  champion   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_competitions_on_season   (season)
#  index_competitions_on_team_id  (team_id)
#

class Competition < ApplicationRecord
  belongs_to :team
  has_many :stages, dependent: :destroy

  PERMITTED_ATTRIBUTES = %i[
    season
    name
    champion
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :season, presence: true
  validates :name, presence: true
end
