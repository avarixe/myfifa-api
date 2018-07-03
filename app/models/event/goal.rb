# == Schema Information
#
# Table name: match_events
#
#  id          :integer          not null, primary key
#  match_id    :integer
#  parent_id   :integer
#  type        :string
#  minute      :integer
#  player_name :string
#  player_id   :integer
#  detail      :string
#  home        :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_match_events_on_match_id   (match_id)
#  index_match_events_on_parent_id  (parent_id)
#  index_match_events_on_player_id  (player_id)
#

class Event::Goal < MatchEvent
  attr_accessor :assisted_by

  has_one :assist,
          class_name: 'Event::Assist',
          foreign_key: :parent_id,
          inverse_of: :goal,
          dependent: :delete

  DETAIL_TYPES = [
    'Penalty',
    'Free Kick'
  ].freeze

  validates :detail,
            inclusion: { in: DETAIL_TYPES },
            allow_nil: true

  def self.permitted_attributes
    super + [:assisted_by]
  end

  after_create :generate_assist

  def generate_assist
    create_assist player_name: assisted_by,
                  minute: minute,
                  team: team,
                  home: home
  end

end
