# frozen_string_literal: true

# == Schema Information
#
# Table name: penalty_shootouts
#
#  id         :bigint           not null, primary key
#  away_score :integer
#  home_score :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_id   :bigint
#
# Indexes
#
#  index_penalty_shootouts_on_match_id  (match_id)
#

class PenaltyShootout < ApplicationRecord
  include Broadcastable

  belongs_to :match

  PERMITTED_ATTRIBUTES = %i[
    home_score
    away_score
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :home_score, numericality: { only_integer: true }
  validates :away_score, numericality: { only_integer: true }
  validate :drawn_match?
  validate :no_draw?

  def drawn_match?
    return if match.home_score == match.away_score

    errors.add :match, 'Result must be a draw'
  end

  def no_draw?
    return if home_score != away_score

    errors.add :base, 'Penalty Shootout must have a winner'
  end

  delegate :team, :home, :away, to: :match
end
