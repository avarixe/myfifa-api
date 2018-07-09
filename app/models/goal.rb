# == Schema Information
#
# Table name: goals
#
#  id          :integer          not null, primary key
#  match_id    :integer
#  minute      :integer
#  player_name :string
#  player_id   :integer
#  assist_id   :integer
#  home        :boolean          default(FALSE)
#  own_goal    :boolean          default(FALSE)
#  penalty     :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_goals_on_assist_id  (assist_id)
#  index_goals_on_match_id   (match_id)
#  index_goals_on_player_id  (player_id)
#

class Goal < ApplicationRecord
  belongs_to :match
  belongs_to :player, optional: true
  belongs_to :assisted_by,
             foreign_key: :assist_id,
             class_name: 'Player',
             optional: true,
             inverse_of: :assists

  PERMITTED_ATTRIBUTES = %i[
    minute
    player_name
    player_id
    assist_id
    home
    own_goal
    penalty
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :minute, inclusion: 1..120

end
