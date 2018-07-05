# == Schema Information
#
# Table name: player_histories
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  datestamp  :date
#  ovr        :integer
#  value      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
  validate :player_changed?

  def player_changed?
    if ovr.blank? || value.blank?
      errors.add(:base, :invalid)
    end
  end

  delegate :current_date, to: :player

  after_initialize :set_datestamp

  def set_datestamp
    self.datestamp ||= current_date
  end
end
