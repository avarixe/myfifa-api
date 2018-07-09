# == Schema Information
#
# Table name: substitutions
#
#  id             :integer          not null, primary key
#  match_id       :integer
#  minute         :integer
#  player_id      :integer
#  replacement_id :integer
#  injury         :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_substitutions_on_match_id        (match_id)
#  index_substitutions_on_player_id       (player_id)
#  index_substitutions_on_replacement_id  (replacement_id)
#

class Substitution < ApplicationRecord
  belongs_to :match
  belongs_to :player
  belongs_to :replacement, class_name: 'Player'

  PERMITTED_ATTRIBUTES = %i[
    minute
    player_id
    replacement_id
    injury
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :minute, inclusion: 1..120
end
