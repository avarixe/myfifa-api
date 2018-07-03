# == Schema Information
#
# Table name: match_events
#
#  id          :integer          not null, primary key
#  match_id    :integer
#  parent_id   :integer
#  type        :string
#  minute      :integer
#  player_name :string
#  player_id   :integer
#  detail      :string
#  home        :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_match_events_on_match_id   (match_id)
#  index_match_events_on_parent_id  (parent_id)
#  index_match_events_on_player_id  (player_id)
#

class MatchEvent < ApplicationRecord
  belongs_to :match
  belongs_to :player, optional: true

  EVENT_TYPES = %w[
    starts
    goals
    assists
    own_goals
    sub_ins
    sub_outs
    injuries
    bookings
    penalty_shootouts
  ].freeze

  TEAM_TYPES = %w[
    home
    away
  ].freeze

  PERMITTED_ATTRIBUTES = %i[
    minute
    team
    player_name
    detail
    home
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  scope :home, -> { where(home: true) }
  scope :away, -> { where(home: false) }

  validates :team, inclusion: { in: TEAM_TYPES }

  before_save :set_player_id

  def set_player_id
    if player_name.present?
      named_player = team.players.active.select(:id).find_by_name(player_name)
      named_player && write_attribute(:played_id, named_player.id)
    end
  end

  delegate :team, to: :match

end
