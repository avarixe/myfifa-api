# == Schema Information
#
# Table name: substitutions
#
#  id             :bigint(8)        not null, primary key
#  match_id       :bigint(8)
#  minute         :integer
#  player_id      :bigint(8)
#  replacement_id :bigint(8)
#  injury         :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  player_name    :string
#  replaced_by    :string
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
    replaced_by
    replacement_id
    injury
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :minute, inclusion: 1..120

  def home
    match.team_home?
  end

  def event_type
    'Substitution'
  end

  def as_json(options = {})
    super((options || {}).merge({
      methods: %i[ event_type home ]
    }))
  end

end
