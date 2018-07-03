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

class Event::SubOut < MatchEvent
  attr_accessor :replaced_by

  has_one :sub_in,
          class_name: 'Event::SubIn',
          foreign_key: :parent_id,
          inverse_of: :sub_out,
          dependent: :delete

  def self.permitted_attributes
    super + [:replaced_by]
  end

  after_create :generate_sub_in

  def generate_sub_in
    create_sub_in player_name: replaced_by,
                  minute: minute,
                  team: team,
                  home: home
  end

end
