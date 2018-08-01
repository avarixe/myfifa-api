# == Schema Information
#
# Table name: goals
#
#  id          :bigint(8)        not null, primary key
#  match_id    :bigint(8)
#  minute      :integer
#  player_name :string
#  player_id   :bigint(8)
#  assist_id   :bigint(8)
#  home        :boolean          default(FALSE)
#  own_goal    :boolean          default(FALSE)
#  penalty     :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  assisted_by :string
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
  belongs_to :assisting_player,
             foreign_key: :assist_id,
             class_name: 'Player',
             optional: true,
             inverse_of: :assists

  PERMITTED_ATTRIBUTES = %i[
    minute
    player_name
    player_id
    assisted_by
    assist_id
    home
    own_goal
    penalty
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :minute, inclusion: 1..120
  validates :player_name, presence: true

  def player_id=(val)
    self.player_name = Player.find(val).name
    super
  end

  def assist_id=(val)
    self.assisted_by = Player.find(val).name
    super
  end

  def away?
    !home?
  end

  def event_type
    'Goal'
  end

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] << :event_type
    super
  end
end
