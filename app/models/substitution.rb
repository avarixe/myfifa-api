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
    player_name
    player_id
    replaced_by
    replacement_id
    injury
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :minute, inclusion: 1..120

  after_create :create_sub_log
  after_destroy :delete_sub_log

  def create_sub_log
    replaced_log = match.performances.find_by(player_id: player_id)
    return unless replaced_log
    replaced_log.update(stop: minute, subbed_out: true)
    match.performances.create player_id: replacement_id,
                              pos:       replaced_log.pos,
                              start:     minute
  end

  def delete_sub_log
    match
      .performances
      .find_by(player_id: replacement_id)
      .destroy
    match
      .performances
      .find_by(player_id: player_id)
      .update(stop: 90, subbed_out: false)
  end

  def home
    match.team_home?
  end

  def event_type
    'Substitution'
  end

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] += %i[event_type home]
    super
  end
end
