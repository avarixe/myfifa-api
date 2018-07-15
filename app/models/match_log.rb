# == Schema Information
#
# Table name: match_logs
#
#  id         :bigint(8)        not null, primary key
#  match_id   :bigint(8)
#  player_id  :bigint(8)
#  pos        :string
#  start      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  stop       :integer
#  subbed_out :boolean          default(FALSE)
#
# Indexes
#
#  index_match_logs_on_match_id   (match_id)
#  index_match_logs_on_player_id  (player_id)
#

class MatchLog < ApplicationRecord
  belongs_to :match
  belongs_to :player

  PERMITTED_ATTRIBUTES = %i[
    player_id
    pos
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :start, inclusion: 0..120
  validates :stop, inclusion: 0..120

  after_initialize :set_defaults

  def set_defaults
    self.start ||= 0
    self.stop ||= 90
  end

  delegate :team, to: :match
  delegate :name, to: :player
end
