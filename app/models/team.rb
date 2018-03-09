# == Schema Information
#
# Table name: teams
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  title        :string
#  start_date   :date
#  current_date :date
#  active       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_teams_on_user_id  (user_id)
#

class Team < ApplicationRecord
  belongs_to :user, optional: true
  has_many :players, dependent: :destroy

  PERMITTED_ATTRIBUTES = %i[
    start_date
    title
    current_date
  ].freeze

  def self.permitted_create_attributes
    PERMITTED_ATTRIBUTES
  end

  def self.permitted_update_attributes
    PERMITTED_ATTRIBUTES.drop 1
  end

  validates :title, presence: true
  validates :start_date, presence: true

  before_save :set_current_date
  after_save :start_new_contracts
  after_save :close_expired_contracts

  def set_current_date
    self.current_date ||= start_date
  end

  def start_new_contracts
    players.includes(:contracts).where(status: nil).each do |player|
      if player.contracts && player.contracts.last.active?
        player.update(status: 'active')
      end
    end
  end

  def close_expired_contracts
    players.includes(:contracts).where.not(status: nil).each do |player|
      player.contracts.expired? && player.update(status: nil)
    end
  end
end
