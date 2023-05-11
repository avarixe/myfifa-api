# frozen_string_literal: true

# == Schema Information
#
# Table name: player_histories
#
#  id          :bigint           not null, primary key
#  kit_no      :integer
#  ovr         :integer
#  recorded_on :date
#  value       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  player_id   :bigint
#
# Indexes
#
#  index_player_histories_on_player_id  (player_id)
#

class PlayerHistory < ApplicationRecord
  include Broadcastable

  belongs_to :player

  validates :recorded_on, presence: true
  validates :ovr, numericality: { only_integer: true }
  validates :value, numericality: { only_integer: true }
  validates :kit_no, numericality: { only_integer: true }, allow_nil: true

  before_validation :set_recorded_on
  before_create :remove_duplicates
  after_save :update_cached_cap_ovrs, if: :saved_change_to_ovr?

  def set_recorded_on
    self.recorded_on ||= team.currently_on
  end

  def remove_duplicates
    PlayerHistory
      .where(player_id:, recorded_on: team.currently_on)
      .delete_all
  end

  def update_cached_cap_ovrs
    next_on = player.histories
                    .where('recorded_on > ?', recorded_on)
                    .order(:recorded_on)
                    .pick(:recorded_on)
    player.caps.joins(:match)
          .where(matches: { played_on: recorded_on...next_on })
          .update_all(ovr:) # rubocop:disable Rails/SkipsModelValidations
  end

  delegate :team, to: :player
end
