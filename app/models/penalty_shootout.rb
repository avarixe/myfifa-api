# == Schema Information
#
# Table name: penalty_shootouts
#
#  id         :integer          not null, primary key
#  match_id   :integer
#  home_score :integer
#  away_score :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_penalty_shootouts_on_match_id  (match_id)
#

class PenaltyShootout < ApplicationRecord
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

end
