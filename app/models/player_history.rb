# frozen_string_literal: true

# == Schema Information
#
# Table name: player_histories
#
#  id          :bigint(8)        not null, primary key
#  player_id   :bigint(8)
#  recorded_on :date
#  ovr         :integer
#  value       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  kit_no      :integer
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
  validate :player_changed?

  def player_changed?
    return unless ovr.blank? && value.blank?

    errors.add(:base, :invalid)
  end

  delegate :currently_on, to: :player

  before_create :remove_duplicates
  before_validation :set_recorded_on

  def remove_duplicates
    PlayerHistory
      .where(player_id: player_id, recorded_on: currently_on)
      .delete_all
  end

  def set_recorded_on
    self.recorded_on ||= currently_on
  end
end
