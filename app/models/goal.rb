# frozen_string_literal: true

# == Schema Information
#
# Table name: goals
#
#  id            :bigint           not null, primary key
#  assisted_by   :string
#  home          :boolean          default(FALSE), not null
#  minute        :integer
#  own_goal      :boolean          default(FALSE), not null
#  penalty       :boolean          default(FALSE), not null
#  player_name   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assist_cap_id :bigint
#  assist_id     :bigint
#  cap_id        :bigint
#  match_id      :bigint
#  player_id     :bigint
#
# Indexes
#
#  index_goals_on_assist_cap_id  (assist_cap_id)
#  index_goals_on_assist_id      (assist_id)
#  index_goals_on_cap_id         (cap_id)
#  index_goals_on_match_id       (match_id)
#  index_goals_on_player_id      (player_id)
#

class Goal < ApplicationRecord
  include Broadcastable

  belongs_to :match
  belongs_to :player, optional: true
  belongs_to :cap, optional: true
  belongs_to :assisting_player,
             foreign_key: :assist_id,
             class_name: 'Player',
             optional: true,
             inverse_of: :assists
  belongs_to :assist_cap,
             class_name: 'Cap',
             optional: true,
             inverse_of: :assists

  validates :minute, inclusion: 1..120
  validates :player_name, presence: true

  before_validation :set_player, if: -> { cap_id.present? }
  before_validation :set_assisting_player, if: -> { assist_cap_id.present? }
  after_create :increment_score
  after_update :update_score, if: :score_changed?
  after_destroy :decrement_score

  def set_player
    self.player_id = cap.player_id
    self.player_name = player.name
  end

  def set_assisting_player
    self.assist_id = assist_cap.player_id
    self.assisted_by = assisting_player.name
  end

  def increment_score
    if home? ^ own_goal?
      match.home_score += 1
    else
      match.away_score += 1
    end
    match.save!
  end

  def decrement_score
    if home? ^ own_goal?
      match.home_score -= 1
    else
      match.away_score -= 1
    end
    match.save!
  end

  def update_score
    if home? == own_goal?
      match.home_score -= 1
      match.away_score += 1
    else
      match.home_score += 1
      match.away_score -= 1
    end
    match.save!
  end

  def score_changed?
    saved_change_to_home? != saved_change_to_own_goal? &&
      (saved_change_to_home? || saved_change_to_own_goal?)
  end

  delegate :team, to: :match
end
