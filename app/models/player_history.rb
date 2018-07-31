# == Schema Information
#
# Table name: player_histories
#
#  id         :bigint(8)        not null, primary key
#  player_id  :bigint(8)
#  datestamp  :date
#  ovr        :integer
#  value      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  kit_no     :integer
#
# Indexes
#
#  index_player_histories_on_player_id  (player_id)
#

class PlayerHistory < ApplicationRecord
  belongs_to :player

  validates :datestamp, presence: true
  validates :ovr, numericality: { only_integer: true }, allow_nil: true
  validates :value, numericality: { only_integer: true }, allow_nil: true
  validates :kit_no, numericality: { only_integer: true }, allow_nil: true
  validate :player_changed?

  def player_changed?
    return unless ovr.blank? || value.blank?
    errors.add(:base, :invalid)
  end

  delegate :current_date, to: :player

  after_initialize :set_datestamp

  def set_datestamp
    self.datestamp ||= current_date
  end
end
