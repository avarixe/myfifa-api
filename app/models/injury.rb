# frozen_string_literal: true

# == Schema Information
#
# Table name: injuries
#
#  id          :bigint           not null, primary key
#  description :string
#  ended_on    :date
#  started_on  :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  player_id   :bigint
#
# Indexes
#
#  index_injuries_on_player_id  (player_id)
#

class Injury < ApplicationRecord
  include Broadcastable

  belongs_to :player

  scope :active_for, lambda { |team:|
    joins(:player)
      .where(players: { team_id: team.id })
      .where(started_on: nil..team.currently_on)
      .where('ended_on > ?', team.currently_on)
  }

  #################
  #  VALIDATIONS  #
  #################

  validates :description, presence: true
  validates :started_on, presence: true
  validates :ended_on, date: { after_or_equal_to: :started_on }
  validate :no_double_injury, on: :create

  def no_double_injury
    return unless player.injured?

    errors.add :base, 'Player can not be injured when already injured.'
  end

  ###############
  #  CALLBACKS  #
  ###############

  after_create :update_status
  after_update :update_status, if: :saved_change_to_ended_on

  ##############
  #  MUTATORS  #
  ##############

  def duration=(val)
    return unless val.is_a?(Hash) &&
                  val[:length].is_a?(Integer) &&
                  %w[Days Weeks Months Years].include?(val[:timespan])

    self.ended_on = started_on +
                    val[:length].public_send(val[:timespan].downcase)
    @duation_set = true
  end

  def ended_on=(val)
    super unless @duration_set
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, :update_status, to: :player

  def current?
    started_on <= team.currently_on && team.currently_on < ended_on
  end
end
