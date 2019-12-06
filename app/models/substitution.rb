# frozen_string_literal: true

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
  include Broadcastable

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

  before_validation :set_names
  after_create :create_cap
  after_update :update_subbed_cap, if: :saved_change_to_player_id?
  after_update :update_sub_cap, if: :saved_change_to_replacement_id?
  after_destroy :delete_cap

  def set_names
    self.player_name = player.name if player_id.present?
    self.replaced_by = replacement.name if replacement_id.present?
  end

  def create_cap
    return unless subbed_cap

    subbed_cap.update(stop: minute, subbed_out: true)
    match.caps.create player_id: replacement_id,
                      pos: subbed_cap.pos,
                      start: minute,
                      stop: match_stop
  end

  def update_subbed_cap
    match
      .caps
      .find_by(player_id: player_id_before_last_save)
      .update(stop: match_stop, subbed_out: false)
    subbed_cap.update(stop: minute, subbed_out: true)
  end

  def update_sub_cap
    match
      .caps
      .find_by(player_id: replacement_id_before_last_save)
      .update(player_id: replacement_id)
  end

  def delete_cap
    sub_cap.destroy
    subbed_cap.update(stop: match_stop, subbed_out: false)
  end

  delegate :team, to: :match

  def home
    match.team_home?
  end

  def event_type
    'Substitution'
  end

  def subbed_cap
    match.caps.find_by(player_id: player_id)
  end

  def sub_cap
    match.caps.find_by(player_id: replacement_id)
  end

  def match_stop
    match.extra_time? ? 120 : 90
  end

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] += %i[event_type home]
    super
  end
end
