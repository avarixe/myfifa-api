# frozen_string_literal: true

# == Schema Information
#
# Table name: substitutions
#
#  id             :bigint           not null, primary key
#  injury         :boolean          default(FALSE), not null
#  minute         :integer
#  player_name    :string
#  replaced_by    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  cap_id         :bigint
#  match_id       :bigint
#  player_id      :bigint
#  replacement_id :bigint
#  sub_cap_id     :bigint
#
# Indexes
#
#  index_substitutions_on_cap_id          (cap_id)
#  index_substitutions_on_match_id        (match_id)
#  index_substitutions_on_player_id       (player_id)
#  index_substitutions_on_replacement_id  (replacement_id)
#  index_substitutions_on_sub_cap_id      (sub_cap_id)
#

class Substitution < ApplicationRecord
  include Broadcastable

  belongs_to :match
  belongs_to :player
  belongs_to :subbed_cap,
             foreign_key: :cap_id,
             class_name: 'Cap',
             inverse_of: :sub_out
  belongs_to :replacement, class_name: 'Player'
  belongs_to :sub_cap,
             class_name: 'Cap',
             inverse_of: :sub_in,
             optional: true,
             dependent: :destroy

  validates :minute, inclusion: 1..120

  before_validation :set_player, if: -> { cap_id.present? }
  before_validation :set_replaced_by, if: -> { replacement_id.present? }
  after_create :create_cap
  after_update :update_subbed_cap, if: :saved_change_to_cap_id?
  after_update :update_sub_cap, if: :saved_change_to_replacement_id?
  after_destroy :restore_subbed_cap

  def set_player
    self.player_id = subbed_cap.player_id
    self.player_name = player.name
  end

  def set_replaced_by
    self.replaced_by = replacement.name
  end

  def create_cap
    subbed_cap.update(stop: minute, subbed_out: true)
    create_sub_cap match_id:,
                   player_id: replacement_id,
                   pos: subbed_cap.pos,
                   start: minute,
                   stop: match_stop
  end

  def update_subbed_cap
    match.caps.find(cap_id_before_last_save)
         .update(stop: match_stop, subbed_out: false)
    subbed_cap.update(stop: minute, subbed_out: true)
  end

  def update_sub_cap
    sub_cap.update(player_id: replacement_id)
  end

  def restore_subbed_cap
    subbed_cap.update(stop: match_stop, subbed_out: false)
  end

  delegate :team, to: :match

  def match_stop = match.extra_time? ? 120 : 90
end
